@CordovaMedia =
  pickLocalFile: ->
    # TODO: Get file from local fs/photo library
    return
  capturePhoto: ->
    camera = new Camera()
    camera.captureImage()
  captureAudio: ->
    recorder = new AudioRecorder().captureAudio()
    return
  captureVideo: ->
    # TODO: Record video from webcam or phone camera
    return

class AudioRecorder
  captureSuccess = (mediaFile) ->
    console.log "Success!"  
    path =  cordova.file.tempDirectory + mediaFile[0].name
    console.log path
    window.resolveLocalFileSystemURL path, gotFile, fail
  captureError = (error) ->
    console.log "Something went wrong: " + error 
    return
  captureAudio : ->
    console.log "Begin Recording"
    navigator.device.capture.captureAudio(captureSuccess, captureError)

class Camera
  captureSuccess = (mediaFile) ->
    console.log "Success!"  
    path =  cordova.file.tempDirectory + mediaFile[0].name
    console.log path
    window.resolveLocalFileSystemURL path, gotFile, fail
  captureError = (error) ->
    alert('Error code: ' + error.code, null, 'Capture Error');
  captureImage : ->
    navigator.device.capture.captureImage(captureSuccess, captureError);



fail = (e) ->
  console.log "FileSystem Error"
  console.dir e
  return
gotFile = (fileEntry) ->
  fileEntry.file (file) ->
    reader = new FileReader()
    reader.onloadend = (e) ->
      console.log "Text is: " + @result
      console.log typeof(@result)
      blob = new Uint8Array(@result)
      Meteor.call "upload", fileEntry.name , blob 
      return
    reader.readAsArrayBuffer file
    return
