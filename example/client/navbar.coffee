Template.navBar.events
  'input #current-search': (e) ->
    currentSearch = $(e.target).val()
    Session.set 'currentSearch', currentSearch

Template.navBar.helpers
  currentSearch: ->
    Session.get 'currentSearch'

