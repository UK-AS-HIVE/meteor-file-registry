Meteor.publish 'fileRegistry', ->
  FileRegistry.find()

Meteor.publish 'jobQueue', ->
  Jobs.find {}, {limit: 10, sort: {submitTime: -1}}

