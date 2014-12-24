Meteor.startup ->
  # Starting up, ensure all thumbnails and checksums are ready
  fs = Npm.require 'fs'
  FileRegistry.find().forEach (f) ->
    Workers.push new ThumbnailJob filenameOnDisk: f.filenameOnDisk
    Workers.push new Md5Job filenameOnDisk: f.filenameOnDisk

