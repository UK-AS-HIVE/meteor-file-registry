execProcesses = (cmd) ->
  if cmd instanceof Array
    r = null
    for c in cmd
      r = execProcesses c
    return r

  exec = Npm.require('child_process').exec
  Future = Npm.require 'fibers/future'
  cwd = process.cwd().substr(0, process.cwd().lastIndexOf('.meteor'))

  p = exec cmd, cwd: cwd
  f = new Future()
  parse_text = ''

  p.stdout.on 'data', (data) ->
    #Workers.log 'stdout: ' + data
    parse_text += data
  p.on 'close', (code, signal) =>
    f.return parse_text

  return f.wait()

class @ThumbnailJob extends Job
  handleJob: ->
    fr = FileRegistry.getFileRoot()
    fd = @params.filenameOnDisk
    src = fr+fd
    thumbnail = fd.substr(0,fd.lastIndexOf('.'))+'_thumbnail.jpg'
    dst = fr+thumbnail
    ext = fd.substr(fd.lastIndexOf('.')).toLowerCase()
    cmd = "convert \"#{src}[0]\" -resize 128x128 \"#{dst}\""

    execProcesses cmd

    FileRegistry.update {filenameOnDisk: @params.filenameOnDisk}, {$set: {thumbnail: thumbnail} }
    Cluster.log 'ThumbnailJob: thumbnailed ', @params.filenameOnDisk

class @Md5Job extends Job
  handleJob: ->
    fn = @params.filenameOnDisk
    md5 = execProcesses('md5 "'+FileRegistry.getFileRoot()+fn+'"')
    md5 = md5.substr(md5.length-32)
    Cluster.log 'Md5Job: ', fn, '-', md5

    FileRegistry.update {filenameOnDisk: fn}, {$set: {md5: md5} }

class @ExecJob extends Job
  handleJob: ->
    execProcesses @params.cmd
    #Workers.log 'Exec: ' + @params.command.command + ' ' + (if @params.command.args.join? then @params.command.args.join(' ') else @params.command.args)

class @VideoTranscodeJob extends Job

  handleJob: ->
    fn = FileRegistry.findOne({filenameOnDisk: @params.filenameOnDisk}).filename
    fr = FileRegistry.getFileRoot()
    src = '"'+fr+@params.filenameOnDisk+'"'
    converted = fn.substr(0, fn.lastIndexOf('.')) + '.' + @params.targetType
    convertedFn = @params.filenameOnDisk.substr(0,@params.filenameOnDisk.lastIndexOf('.'))+'.'+@params.targetType
    dst = '"'+fr+convertedFn+'"'
    cmd = ["ffmpeg -i #{src} -y #{dst}"]
    execProcesses cmd

  afterJob: ->
    fs = Npm.require 'fs'
    #Not sure if there's a better way than just redoing all of our file name stuff. Not much of this is intensive though.
    fn = FileRegistry.findOne({filenameOnDisk: @params.filenameOnDisk}).filename
    fr = FileRegistry.getFileRoot()
    src = '"'+fr+@params.filenameOnDisk+'"'
    converted = fn.substr(0, fn.lastIndexOf('.')) + '.' + @params.targetType
    convertedFn = @params.filenameOnDisk.substr(0,@params.filenameOnDisk.lastIndexOf('.'))+'.'+@params.targetType
    dst = fr+convertedFn
    stats = fs.statSync dst
    FileRegistry.insert
      filename: converted
      filenameOnDisk: convertedFn
      size: stats['size']
      timestamp: new Date()
      userId: @userId

    #Get an Md5 and Thumbnail for our new file.
    Job.push new Md5Job filenameOnDisk: convertedFn
    Job.push new ThumbnailJob filenameOnDisk: convertedFn

    Cluster.log 'VideoTranscodeJob: converted ', @params.filenameOnDisk, 'to type ', @params.targetType
