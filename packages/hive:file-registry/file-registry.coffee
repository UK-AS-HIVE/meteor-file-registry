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
    videos = ['mp4', 'mpeg', 'avi', 'mov', 'webm', 'flv', 'mkv', '3gp', 'm4v', '3g2', 'm2v'] #This is a pretty extensive list
    Job.push new Md5Job filenameOnDisk: filenameOnDisk
    if endsWithAnyOf filenameOnDisk, images.concat(videos)
      Job.push new ThumbnailJob filenameOnDisk: filenameOnDisk
    if endsWithAnyOf filenameOnDisk, videos
      targetType = Meteor.settings.fileRegistry?.videoTargetType? or 'mp4'
      unless filenameOnDisk.toLowerCase().lastIndexOf(targetType.toLowerCase()) is filenameOnDisk.length-targetType.length #Don't convert something to the same type.
        Job.push new VideoTranscodeJob filenameOnDisk: filenameOnDisk, targetType: targetType
