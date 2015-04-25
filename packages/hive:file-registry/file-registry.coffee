FileRegistry = new Mongo.Collection 'fileRegistry'
###@FileRegistry.attachSchema new SimpleSchema
  filename:
    type: String
  filenameOnDisk:
    type: String
  size:
    type: Number
  timestamp:
    type: new Date()
  userId:
    type: String
###


if Meteor.isServer
  endsWithAnyOf =  (filename, extensions) ->
    check filename, String
    check extensions, Array
 
    f = filename.toLowerCase()
    for e in extensions
      if f.lastIndexOf(e.toLowerCase()) is f.length-e.length then return true
    return false

  FileRegistry.getFileRoot = ->
    fs = Npm.require 'fs'
    filePath = process.cwd()
    localPathIndex = filePath.indexOf('.meteor/local')
    filePath = filePath.substr(0, localPathIndex)+'.meteor' if localPathIndex > -1

    return filePath + '/files/'

  FileRegistry.scheduleJobsForFile = (filenameOnDisk) ->
    #I'm tentatively making this package depend on differential:workers, and moving the jobs into this package.
    #The jobs themselves depend on this package, so either this function should be moved out of this package or the jobs should be moved in.
    images = ['jpg', 'jpeg', 'png', 'gif', 'tif', 'tiff', 'tga', 'bmp', 'cr2']
    videos = ['mp4', 'mpeg', 'avi', 'mov', 'webm', 'flv', 'mkv', '3gp', 'm4v', '3g2', 'm2v', 'wmv'] #This is a pretty extensive list
    Job.push new Md5Job filenameOnDisk: filenameOnDisk
    if endsWithAnyOf filenameOnDisk, images.concat(videos)
      Job.push new ThumbnailJob filenameOnDisk: filenameOnDisk
    if endsWithAnyOf filenameOnDisk, videos
      targetType = Meteor.settings.fileRegistry?.videoTargetType? or 'mp4'
      unless filenameOnDisk.toLowerCase().lastIndexOf(targetType.toLowerCase()) is filenameOnDisk.length-targetType.length #Don't convert something to the same type.
        Job.push new VideoTranscodeJob filenameOnDisk: filenameOnDisk, targetType: targetType


  # Generates an action handler to serve files via iron:router server routes
  # example:
  # @route 'serveFile',
  #   path: '/file/:filename'
  #   where: 'server'
  #   action: FileRegistry.serveFile
  FileRegistry.serveFile = ->
    @check params.filename, String

    fs = Npm.require 'fs'
    # TODO verify file exists
    # TODO permissions check
    expire = new Date()
    expire.setFullYear(expire.getFullYear()+1)
    fd = fs.openSync FileRegistry.getFileRoot() + @params.filename, 'r'
    try
      stat = fs.fstatSync fd
      if @request.headers.range?
        start = parseInt(@request.headers.range.substr('bytes='.length))
        end = parseInt(@request.headers.range.split('-').pop())
        bufferSize = if isNaN(end) then Math.min(1024*1024,stat.size) else (1+end-start)
        console.log 'bufferSize: ', bufferSize
        buffer = new Buffer(bufferSize)
        bytesRead = fs.readSync fd, buffer, 0, bufferSize, Math.min(start, stat.size)
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
    catch e
      console.log 'exception from request: ', @params.filename, @request.headers.range
      console.log e
    finally
      fs.closeSync fd

