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
      filePath = process.cwd()
      localPathIndex = filePath.indexOf('.meteor/local')
      filePath = filePath.substr(0, localPathIndex)+'.meteor' if localPathIndex > -1
      # TODO verify file exists
      # TODO permissions check
      @response.writeHead 200,
        'Content-type': 'image/jpg'
        'Content-Disposition': 'attachment; filename='+@params.filename
      console.log 'serving ', @params.filename
      @response.end fs.readFileSync (filePath + '/files/' + @params.filename)

  @route 'serveThumbnail',
    path: '/thumbnail/:filename'
    where: 'server'
    action: (filename) ->
      # TODO serve thumbnail
      @response.end 'thumbnail'

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

