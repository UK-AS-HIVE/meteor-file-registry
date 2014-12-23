class @ForkJob extends Job
  constructor: (command, args) ->
    super {command: command, args: args}
  handleJob: ->
    #Workers.log 'Fork: ' + @params.command.command + ' ' + (if @params.command.args.join? then @params.command.args.join(' ') else @params.command.args)

    spawn = Npm.require('child_process').spawn
    Future = Npm.require 'fibers/future'
    cwd = process.cwd().substr(0, process.cwd().lastIndexOf('.meteor'))

    #Workers.log '  in: ' + cwd
    p = spawn @params.command.command, @params.command.args,
      cwd: cwd
    f = new Future()
    parse_text = ''

    p.stdout.on 'data', (data) ->
      Workers.log 'stdout ' + data
      parse_text += ''
    p.stderr.on 'data', (data) ->
      Workers.log 'stderr ' + data
    p.on 'close', (code, signal) =>
      #Workers.log 'Ended fork of ' + @params.command.command
      f.return parse_text

    return f.wait()
