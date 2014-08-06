Template.home.events
  'click input[value="Upload"]': ->
    Meteor.call 'upload','test', getMediaFunctions().pickLocalFile()
  'click input[value="Photo"]': ->
    Meteor.call 'upload','test', getMediaFunctions().capturePhoto()
  'click input[value="Audio"]': ->
    Meteor.call 'upload','test', getMediaFunctions().captureAudio()
  'click input[value="Video"]': ->
    Meteor.call 'upload','test', getMediaFunctions().captureVideo()

# TODO: figure out when and where to run
getMediaFunctions = ->
  requiredFunctions = ['pickLocalFile', 'capturePhoto', 'captureAudio', 'captureVideo']

  RunningInCordova = ->
    /iPhone|iPad|iPod|Android/i.test navigator.platform

  if RunningInCordova()
    CordovaMedia
  else
    WebMedia

