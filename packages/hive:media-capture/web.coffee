@WebMedia =
  pickLocalFile: (cb) ->
    fileInput = $('<input type="file" multiple />')
    fileInput.on 'change', (e) ->
      console.log e.target.files
      _.each e.target.files, (f) -> sendFile f, cb
    fileInput.trigger 'click'
    return
  capturePhoto: ->
    # TODO: Take snapshot from webcam or phone camera
    return
  captureAudio: ->
    # TODO: Record audio from microphone
    return
  captureVideo: ->
    # TODO: Record video from webcam or phone camera
    return

