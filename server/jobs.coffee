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
    Workers.log 'stderr: ' + data
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
    #Workers.log 'ThumbnailJob: thumbnailed ', @params.filenameOnDisk

class @Md5Job extends Job
  handleJob: ->
    fn = @params.filenameOnDisk
    md5 = execProcesses('md5 "'+FileRegistry.getFileRoot()+fn+'"')
    md5 = md5.substr(md5.length-32)
    #Workers.log 'Md5Job: ', fn, '-', md5

    FileRegistry.update {filenameOnDisk: fn}, {$set: {md5: md5} }

class @ExecJob extends Job
  handleJob: ->
    execProcesses @params.cmd
    #Workers.log 'Exec: ' + @params.command.command + ' ' + (if @params.command.args.join? then @params.command.args.join(' ') else @params.command.args)


