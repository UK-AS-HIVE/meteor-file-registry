endsWithAnyOf = (filename, extensions) ->
  check filename, String
  check extensions, Array

  f = filename.toLowerCase()

  for e in extensions
    if f.lastIndexOf(e.toLowerCase()) is f.length-e.length then return true
  return false

Template.home.helpers
  connectionStatus: ->
    Meteor.status().status
  rootUrl: ->
    if Meteor.isCordova
      __meteor_runtime_config__.ROOT_URL.replace(/\/$/, '') + __meteor_runtime_config__.ROOT_URL_PATH_PREFIX
    else
      __meteor_runtime_config__.ROOT_URL.replace /\/$/, ''
  mediaFiles: ->
    currentSearch = Session.get('currentSearch') || ''
    FileRegistry.find({filename: {$regex: currentSearch, $options: 'i'}}, {sort: {timestamp: -1}})
  friendlySize: (bytes) ->
    if bytes > 1024*1024
      return (bytes/(1024*1024)).toFixed(2) + 'MB'
    else if bytes > 1024
      return (bytes/1024).toFixed(2) + 'KB'
    else
      return bytes
  isVideo: ->
    endsWithAnyOf @filename, ['.mov', '.mp4', '.avi', '.mpeg', '.mkv', '.flv', '.3gp', '.3g2', '.m4v', '.m2v', '.webm', '.wmv']
  isImage: ->
    endsWithAnyOf @filename, ['.jpg', '.jpeg', '.png', '.gif']
  moment: (d) ->
    moment(d).fromNow()
  cardMode: ->
    Session.setDefault 'cardMode', false
    Session.get 'cardMode'

Template.home.events
  'click input[value="Upload"]': ->
    Media.pickLocalFile()
  'click input[value="Photo"]': ->
    Media.capturePhoto()
  'click input[value="Audio"]': ->
    Media.captureAudio()
  'click input[value="Video"]': ->
    Media.captureVideo()
  'click input[value="Thumbnails"]': ->
    Session.set 'cardMode', false
  'click input[value="Cards"]': ->
    Session.set 'cardMode', true

Jobs = new Meteor.Collection 'jobs'

Template.jobQueue.helpers
  job: -> Jobs.find({}, {sort: {ended: -1}})
  inspect: (o) -> JSON.stringify o
  moment: (d) -> moment(d).fromNow()

