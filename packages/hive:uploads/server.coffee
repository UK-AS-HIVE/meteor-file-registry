Meteor.methods
  'upload': (filename, data) ->
    check filename, String
    check data, Uint8Array

    fs = Npm.require 'fs'

    # Make sure we aren't deep in the build structure
    if process.cwd().indexOf('.meteor/local') > -1
      process.chdir '../../../..'

    # Make sure directory to store uploads in exists
    if not fs.existsSync('./files')
      fs.mkdirSync './files'

    now = new Date()
    fn = @connection.id + '-' + filename
    fs.writeFileSync './files/' + fn, new Buffer(data)

    FileRegistry.insert
      filename: filename
      filenameOnDisk: fn
      size: data.length
      timestamp: now
      userId: @userId

  'uploadSlice': (filename, data, offset) ->
    console.log 'uploadSlice', filename, offset

    check filename, String
    check data, Uint8Array
    check offset, Number

    @unblock()

    fs = Npm.require 'fs'

    # Make sure we aren't deep in the build structure
    if process.cwd().indexOf('.meteor/local') > -1
      process.chdir '../../../..'

    # Make sure directory to store uploads in exists
    if not fs.existsSync('./files')
      fs.mkdirSync './files'

    now = new Date()
    fn = @connection.id + '-' + filename
    fs.appendFileSync './files/' + fn, new Buffer(data)

    f = FileRegistry.findOne {filename: filename, filenameOnDisk: fn, userId: @userId}
    if f?
      FileRegistry.update f._id,
        $set:
          size: f.size+data.length
    else
      FileRegistry.insert
        filename: filename
        filenameOnDisk: fn
        size: data.length
        timestamp: now
        userId: @userId

