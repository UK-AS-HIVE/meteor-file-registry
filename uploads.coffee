if Meteor.isClient

  # file - browser File object
  # options - optional object with following keys
  #   immediate - if true, invoke callback function as soon as the file has
  #     begun to upload, instead of waiting for completion
  # cb - if specified, it
  #   will be called with the _id of the newly created FileRegistry document as
  #   its only parameter
  FileRegistry.upload = @sendFile = (file, options, cb) ->
    console.log 'Uploading file', file
    file.slice = file.slice || file.webkitSlice || file.mozSlice
    sliceSize = 1024*256
    console.log 'file is '+file.size+' bytes, so we need to slice into '+(file.size/sliceSize)+' slices'
    cbCalled = false
    uploadId = new Mongo.ObjectID()._str
    if not cb? and typeof options == "function"
      cb = options
      options =
        immediate: false

    console.log 'upload options: ', options

    sendSlice = (file, start, result) ->
      if options.immediate && result && !cbCalled
        cbCalled = true
        cb? result
      if start >= file.size
        console.log 'done sending file!'
        unless options.immediate
          cbCalled = true
          cb? result
        return
      sliceEnd = Math.min(file.size, start+sliceSize)
      slice = file.slice(start, sliceEnd)
      console.log 'Sending slice '+start+' - '+sliceEnd
      reader = new FileReader()
      reader.onloadend = (e) ->
        blob = new Uint8Array(@result)
        Meteor.call "uploadSlice", file.name, uploadId, blob, start, file.size, (error, result) ->
          sendSlice file, sliceEnd, result
      reader.readAsArrayBuffer slice

    sendSlice file, 0
    return

  @sendFileEntry = (fileEntry, cb) ->
    send = (f) ->
      sendFile f, cb
    fileEntry.file send

if Meteor.isServer
  Meteor.methods
    'upload': (filename, data) ->
      check filename, String
      check data, Uint8Array

      fs = Npm.require 'fs'

      filesdir = FileRegistry.getFileRoot()

      # Make sure directory to store uploads in exists
      if not fs.existsSync(filesdir)
        fs.mkdirSync filesdir

      now = new Date()
      fn = @connection.id + '-' + filename
      fs.writeFileSync filesdir + fn, new Buffer(data)

      FileRegistry.insert
        filename: filename
        filenameOnDisk: fn
        size: data.length
        timestamp: now
        userId: @userId

      FileRegistry.scheduleJobsForFile fn

    'uploadSlice': (filename, uploadId, data, offset, total) ->
      console.log 'uploadSlice', filename, offset, data.length, total

      check filename, String
      check data, Uint8Array
      check offset, Number

      #@unblock()

      fs = Npm.require 'fs'

      # Make sure we aren't deep in the build structure
      #if process.cwd().indexOf('.meteor/local') > -1
      #  process.chdir '../../../..'
      #
      filesdir = FileRegistry.getFileRoot()

      # Make sure directory to store uploads in exists
      if not fs.existsSync(filesdir)
        fs.mkdirSync filesdir

      now = new Date()
      fn = @connection.id + '-' + uploadId + '-' + filename
      fs.appendFileSync filesdir + fn, new Buffer(data)

      f = FileRegistry.findOne {filename: filename, filenameOnDisk: fn, userId: @userId}
      if f?
        FileRegistry.update f._id,
          $set:
            uploaded: offset+data.length
      else
        f = _id: FileRegistry.insert
          filename: filename
          filenameOnDisk: fn
          uploaded: offset+data.length
          size: total
          timestamp: now
          userId: @userId

    
      if offset+data.length >= total
        FileRegistry.scheduleJobsForFile fn
        onUploaded f

      return f._id

FileRegistry.onUploaded = (cb) ->
  FileRegistry._uploadedCallbacks = FileRegistry._uploadedCallbacks? || []
  FileRegistry._uploadedCallbacks.push cb

onUploaded = (fileDoc) ->
  _.each FileRegistry._uploadedCallbacks, (cb) -> cb fileDoc

