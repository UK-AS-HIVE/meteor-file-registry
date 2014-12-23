Meteor.startup ->
  console.log 'Starting up, making sure all images have thumbnails'
  fs = Npm.require 'fs'
  FileRegistry.find().forEach (f) ->
    console.log 'Scheduling md5 for ' + f.filename + '...'
    Workers.push new ForkJob('md5', [FileRegistry.getFileRoot()+f.filenameOnDisk])
    console.log 'Making thumbnail for ' + f.filename + '...'
    Workers.push new ForkJob('convert', [FileRegistry.getFileRoot()+f.filenameOnDisk+'[0]','-resize', '64x64',FileRegistry.getFileRoot()+f.filenameOnDisk.substr(0,f.filenameOnDisk.lastIndexOf('.'))+'_thumbnail.jpg'])

