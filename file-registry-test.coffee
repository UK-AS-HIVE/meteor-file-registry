Tinytest.add 'file registry - FileRegistry collection', (test) ->
  id = FileRegistry.insert
    filename: 'file.nam'
    filenameOnDisk: 'userToken-file.nam'
    size: 32*1024*1024
    timestamp: new Date()
    userId: null

  test.isNotNull FileRegistry.findOne(id)

if Meteor.isServer && Npm.require('cluster').isMaster
  Tinytest.add 'file registry - getFileRoot', (test) ->
    fileRoot = FileRegistry.getFileRoot()

    test.isTrue fileRoot.indexOf '/files/' > 0
    test.equal fileRoot[0], '/'

  Tinytest.add 'file registry - scheduleJobsForFile', (test) ->
    FileRegistry.scheduleJobsForFile 'file.nam'

  Tinytest.add 'jobs - ThumbnailJob', (test) ->
    Job.push new ThumbnailJob filenameOnDisk: 'movie.wmv'

  Tinytest.add 'jobs - Md5Job', (test) ->
    Job.push new Md5Job filenameOnDisk: 'movie.mp4'

  Tinytest.add 'jobs - ExecJob', (test) ->
    Job.push new ExecJob cmd: 'echo hello'

  Tinytest.add 'jobs - VideoTranscodeJob', (test) ->
    Job.push new VideoTranscodeJob filenameOnDisk: 'video.avi', targetType: 'mp4'

if Meteor.isClient
  Tinytest.add 'uploads - upload method', (test) ->
    Meteor.call 'upload', 'world.txt', new Uint8Array('hello world'.split ''),
      type: 'text/plain'

  Tinytest.add 'uploads - uploadSlice method', (test) ->
    Meteor.call 'uploadSlice',
      'world.txt',
      new Uint8Array('hello world'.split '', type: 'text/plain'),
      0,
      11

   Tinytest.add 'media web+cordova - pickLocalFile', (test) ->
     Media.pickLocalFile()

   Tinytest.add 'media web+cordova - capturePhoto', (test) ->
     Media.capturePhoto()

   Tinytest.add 'media web+cordova - captureAudio', (test) ->
     Media.captureAudio()

   Tinytest.add 'media web+cordova - captureVideo', (test) ->
     Media.captureVideo()

