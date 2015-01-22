Router.configure
  layoutTemplate: 'layoutTemplate'
  waitOn: -> [Meteor.subscribe 'fileRegistry']

Router.map ->
  @route 'home',
    path: '/'

  @route 'serveFile',
    path: '/file/:filename'
    where: 'server'
    action: ->
      fs = Npm.require 'fs'
      # TODO verify file exists
      # TODO permissions check
      expire = new Date()
      expire.setFullYear(expire.getFullYear()+1)
      if @request.headers.range?
        start = parseInt(@request.headers.range.substr('bytes='.length))
        end = parseInt(@request.headers.range.split('-').pop())
        bufferSize = if isNaN(end) then 1024*1024 else end-start
        buffer = new Buffer(bufferSize)
        fd = fs.openSync FileRegistry.getFileRoot() + @params.filename, 'r'
        stat = fs.fstatSync fd
        bytesRead = fs.readSync fd, buffer, 0, bufferSize, start
        @response.writeHead 206,
          'Content-Range': 'bytes '+start+'-'+(start+bytesRead-1) + '/' + stat.size
          'Content-Length': bytesRead
          'Content-Type': 'video/mp4'
          'Accept-Ranges': 'bytes'
          'Cache-Control': 'no-cache'
        @response.end buffer.slice(0,bytesRead)
      else
        @response.writeHead 200,
          'Content-Disposition': 'attachment; filename='+@params.filename.substr(@params.filename.indexOf('-')+1)
          'Content-type': 'image/jpg'
          'Expires': moment(expire).format('ddd, DD MMM YYYY HH:mm:ss GMT')
        @response.end fs.readFileSync (FileRegistry.getFileRoot() + @params.filename)

  @route 'serveThumbnail',
    path: '/thumbnail/:filename'
    where: 'server'
    action: (filename) ->
      fs = Npm.require 'fs'
      # TODO verify thumbnail exists
      # TODO permissions check
      expire = new Date()
      expire.setFullYear(expire.getFullYear()+1)
      @response.writeHead 200,
        'Content-type': 'image/jpg'
        'Expires': moment(expire).format('ddd, DD MMM YYYY HH:mm:ss GMT')
      @response.end fs.readFileSync (FileRegistry.getFileRoot() + @params.filename.substr(0, @params.filename.lastIndexOf('.')) + '_thumbnail.jpg')

  @route 'exportJSON',
    path: '/export/:dataset/json'
    where: 'server'
    action: (dataset) ->
      # TODO figure out what dataset is and implement
      # 2nd milestone
      @response.end '{json: "here"}'

  @route 'exportCSV',
    path: '/export/:dataset/csv'
    where: 'server'
    action: (dataset) ->
      # TODO ditto
      # 2nd milestone
      @response.end 'csv,file'

