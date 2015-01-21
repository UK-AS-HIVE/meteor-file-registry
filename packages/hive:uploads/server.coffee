Uploads = new Mongo.Collection 'uploads'

Uploads.getFileRoot = ->
  fs = Npm.require 'fs'
  filePath = process.cwd()
  localPathIndex = filePath.indexOf('.meteor/local')
  filePath = filePath.substr(0, localPathIndex)+'.meteor' if localPathIndex > -1

  return filePath + '/files/'

Meteor.methods
  'upload': (filename, data) ->
    check filename, String
    check data, Uint8Array

    fs = Npm.require 'fs'

    # Make sure we aren't deep in the build structure
    #if process.cwd().indexOf('.meteor/local') > -1
    #  process.chdir '../../../..'

    # Make sure directory to store uploads in exists
    #if not fs.existsSync('./files')
    #  fs.mkdirSync './files'

    now = new Date()
    fn = @connection.id + '-' + filename
    fs.writeFileSync './files/' + fn, new Buffer(data)

    #Add to both "Uploads" and "FileRegistry" collections.
    Uploads.insert
      filename: filename
      filenameOnDisk: fn
      size: data.length
      timestamp: now
      userId: @userId

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

    @unblock()

    fs = Npm.require 'fs'

    # Make sure we aren't deep in the build structure
    #if process.cwd().indexOf('.meteor/local') > -1
    #  process.chdir '../../../..'
    #
    filesdir = Uploads.getFileRoot()

    # Make sure directory to store uploads in exists
    if not fs.existsSync(filesdir)
      fs.mkdirSync filesdir

    now = new Date()
    fn = @connection.id + '-' + filename
    fs.appendFileSync filesdir + fn, new Buffer(data)

    f = Uploads.findOne {filename: filename, filenameOnDisk: fn, userId: @userId}
    if f?
      Uploads.update f._id,
        $set:
          uploaded: f.size+data.length
    else
      f = Uploads.insert
        filename: filename
        filenameOnDisk: fn
        uploaded: offset+data.length
        size: total
        timestamp: now
        userId: @userId
    if offset+data.length >= total
      #If the upload is done, add the file to FileRegistry and schedule jobs.
      FileRegistry.insert
        filename: filename
        filenameOnDisk: fn
        size: total
        timestamp: now
        userId: @userId

      FileRegistry.scheduleJobsForFile fn

