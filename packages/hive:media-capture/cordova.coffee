@CordovaMedia =
  pickLocalFile: ->
    # TODO: Get file from local fs/photo library
    return
  capturePhoto: ->
    captureSuccess = (mediaFile) ->
      console.log "Success!"
      console.log (JSON.stringify mediaFile)
      path =  resolvePath(mediaFile[0].fullPath)
      #path =  cordova.file.tempDirectory + mediaFile[0].name
      console.log path
      window.resolveLocalFileSystemURL path, sendFileEntry, fail
    captureError = (error) ->
      console.log('Error code: ' + error.code, null, 'Capture Error')
      console.log('Full error: ' + JSON.stringify(error));

    navigator.device.capture.captureImage(captureSuccess, captureError)
  captureAudio: ->
    captureSuccess = (mediaFile) ->
      console.log "Success!"
      path =  resolvePath(mediaFile[0].fullPath)
      #path =  cordova.file.tempDirectory + mediaFile[0].name
      console.log path
      window.resolveLocalFileSystemURL path, sendFileEntry, fail
    captureError = (error) ->
      console.log "Something went wrong: " + JSON.stringify( error )
    navigator.device.capture.captureAudio(captureSuccess, captureError)
  captureVideo: ->
    captureSuccess = (mediaFile) ->
      console.log "Success!"
      path =  resolvePath(mediaFile[0].fullPath)
      #path =  cordova.file.tempDirectory + mediaFile[0].name
      console.log path
      window.resolveLocalFileSystemURL path, sendFileEntry, fail
    captureError = (error) ->
      console.log "Something went wrong: " + JSON.stringify( error )
    navigator.device.capture.captureVideo(captureSuccess, captureError)
    return

fail = (e) ->
  console.log "FileSystem Error"
  console.dir e
  return

resolvePath = (path) ->
  console.log(path.substr(0,4))
  if (path.substr(0,4) != "file")
    return "file://" + path
  else
    return path
