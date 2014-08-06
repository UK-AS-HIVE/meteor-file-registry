Router.configure
  layoutTemplate: 'layoutTemplate'

Router.map ->
  @route 'home',
    path: '/'

  @route 'serveFile',
    path: '/file/:filename'
    where: 'server'
    action: (filename) ->
      # TODO serve file
      @response.end 'file'

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

