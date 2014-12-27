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
      @response.writeHead 200,
        'Content-Disposition': 'attachment; filename='+@params.filename.substr(@params.filename.indexOf('-')+1)
        'Content-type': 'image/jpg'
        'Expires': moment(expire).format('ddd, DD MMM YYYY HH:mm:ss GMT')
      console.log 'serving ', @params.filename
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

