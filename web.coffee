@Media =
  pickLocalFile: (options, cb) ->
    if typeof options == "function"
      cb = options
      options = {}
    fileInput = $('<input type="file" multiple />')
    if options.attributes?
      for key, value of options.attributes
        $(fileInput).attr(key, value)
      delete options.attributes
    fileInput.on 'change', (e) ->
      console.log e.target.files
      _.each e.target.files, (f) -> sendFile f, options, cb
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

