if Meteor.isClient
  # file - browser File object
  # cb - if specified, it will be called with the _id
  # of the newly created FileRegistry document as its only
  # parameter
  @sendFile = (file, cb) ->
    console.log 'Uploading file', file
    file.slice = file.slice || file.webkitSlice || file.mozSlice
    sliceSize = 1024*256
    console.log 'file is '+file.size+' bytes, so we need to slice into '+(file.size/sliceSize)+' slices'
    cbCalled = false

    sendSlice = (file, start) ->
      if start > file.size
        console.log 'done sending file!'
        return
      slice = file.slice(start, start+sliceSize)
      console.log 'Sending slice '+start+' - '+(start+sliceSize)
      reader = new FileReader()
      reader.onloadend = (e) ->
        blob = new Uint8Array(@result)
        Meteor.call "uploadSlice", file.name , blob, start, file.size, (error, result) ->
          if result? and cbCalled is false and cb?
            cbCalled = true
            cb result
          sendSlice file, start+sliceSize
      reader.readAsArrayBuffer slice

    sendSlice file, 0
    return

  @sendFileEntry = (fileEntry) ->
    fileEntry.file sendFile

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

    'uploadSlice': (filename, data, offset, total) ->
      console.log 'uploadSlice', filename, offset, total

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
      fn = @connection.id + '-' + filename
      fs.appendFileSync filesdir + fn, new Buffer(data)

      f = FileRegistry.findOne {filename: filename, filenameOnDisk: fn, userId: @userId}
      if f?
        FileRegistry.update f._id,
          $set:
            uploaded: f.size+data.length
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
