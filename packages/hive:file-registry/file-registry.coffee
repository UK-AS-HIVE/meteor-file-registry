FileRegistry = new Meteor.Collection 'fileRegistry'
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
    #TODO: This is the wrong place for this. This would make our FileRegistry package dependent on job classes in our app code as well as differential:workers.
    #      Either we need to move these jobs into this package or put them into another one.
    images = ['jpg', 'jpeg', 'png', 'gif']
    videos = ['mp4', 'mpeg', 'avi', 'mov', 'webm', 'flv', 'mkv', '3gp', 'm4v', '3g2', 'm2v'] #This is a pretty extensive list
    Workers.push new Md5Job filenameOnDisk: filenameOnDisk
    if endsWithAnyOf filenameOnDisk, images.concat(videos)
      Workers.push new ThumbnailJob filenameOnDisk: filenameOnDisk
    if endsWithAnyOf filenameOnDisk, videos
        Workers.push new VideoTranscodeJob filenameOnDisk: filenameOnDisk, targetType: 'mp4'
