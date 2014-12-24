@sendFile = (file) ->
  console.log 'Uploading file', file
  file.slice = file.slice || file.webkitSlice || file.mozSlice
  sliceSize = 1024*256
  console.log 'file is '+file.size+' bytes, so we need to slice into '+(file.size/sliceSize)+' slices'

  sendSlice = (file, start) ->
    if start > file.size
      console.log 'done sending file!'
      return
    slice = file.slice(start, start+sliceSize)
    console.log 'Sending slice '+start+' - '+(start+sliceSize)
    reader = new FileReader()
    reader.onloadend = (e) ->
      blob = new Uint8Array(@result)
      Meteor.call "uploadSlice", file.name , blob, start, file.size, ->
        sendSlice file, start+sliceSize
    reader.readAsArrayBuffer slice

  sendSlice file, 0
  return

sendFileEntry = (fileEntry) ->
  fileEntry.file sendFile

