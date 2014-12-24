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
  p.stderr.on 'data', (data) ->
    #Workers.log 'stderr: ' + data
  p.on 'close', (code, signal) =>
    f.return parse_text

  return f.wait()

class @ThumbnailJob extends Job
  handleJob: ->
    fr = FileRegistry.getFileRoot()
    src = '"'+fr+@params.filenameOnDisk+'[0]"'
    thumbnail = @params.filenameOnDisk.substr(0,@params.filenameOnDisk.lastIndexOf('.'))+'_thumbnail.jpg'
    dst = '"'+fr+thumbnail+'"'
    cmd = ["convert #{src} -resize 128x128 #{dst}"]

    execProcesses cmd

    FileRegistry.update {filenameOnDisk: @params.filenameOnDisk}, {$set: {thumbnail: thumbnail} }
    Workers.log 'ThumbnailJob: thumbnailed ', @params.filenameOnDisk

class @Md5Job extends Job
  handleJob: ->
    fn = @params.filenameOnDisk
    md5 = execProcesses('md5 "'+FileRegistry.getFileRoot()+fn+'"')
    md5 = md5.substr(md5.length-32)
    Workers.log 'Md5Job: ', fn, '-', md5

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
    converted = @params.filenameOnDisk.substr(0,@params.filenameOnDisk.lastIndexOf('.'))+'.'+@params.targetType
    convertedFn = fn.substr(0, fn.lastIndexOf('.')) + '.' + @params.targetType
    dst = '"'+fr+converted+'"'
    cmd = ["ffmpeg -i #{src} -y #{dst}"]

    execProcesses cmd
    
    FileRegistry.update {filename: fn}, {$set: {filename: convertedFn, filenameOnDisk: converted } } #Point the FileRegistry to our new converted files. TODO: delete old files?
    Workers.log 'VideoTranscodeJob: converted ', @params.filenameOnDisk, 'to type ', @params.targetType
