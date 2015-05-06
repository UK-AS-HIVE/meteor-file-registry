Meteor.publish 'fileRegistry', ->
  FileRegistry.find({}, {limit: 48, sort: {timestamp: -1}})

Meteor.publish 'jobs', ->
  Jobs.find {}, {limit: 5, sort: {ended: -1}}

