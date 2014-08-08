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
    fn = @connection.id + '-' + now.getTime() + '-' + filename
    fs.writeFileSync './files/' + fn, new Buffer(data)

    FileRegistry.insert
      filename: filename
      size: data.length
      timestamp: now
      userId: @userId

