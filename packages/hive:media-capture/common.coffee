# TODO: move this into hive:uploads
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

