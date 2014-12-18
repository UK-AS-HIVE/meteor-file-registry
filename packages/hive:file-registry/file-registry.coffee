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
  FileRegistry.getFileRoot = ->
    fs = Npm.require 'fs'
    filePath = process.cwd()
    localPathIndex = filePath.indexOf('.meteor/local')
    filePath = filePath.substr(0, localPathIndex)+'.meteor' if localPathIndex > -1

    return filePath + '/files/'

