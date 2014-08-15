Template.home.events
  'click input[value="Upload"]': ->
    getMediaFunctions().pickLocalFile()
  'click input[value="Photo"]': ->
    getMediaFunctions().capturePhoto()
  'click input[value="Audio"]': ->
    getMediaFunctions().captureAudio()
  'click input[value="Video"]': ->
    Meteor.call 'upload','test', getMediaFunctions().captureVideo()

# TODO: figure out when and where to run
getMediaFunctions = ->
  requiredFunctions = ['pickLocalFile', 'capturePhoto', 'captureAudio', 'captureVideo']

  RunningInCordova = ->
    window._cordovaNative? || /iPhone|iPad|iPod|Android/i.test(navigator.userAgent)

  if RunningInCordova()
    CordovaMedia
  else
    WebMedia

