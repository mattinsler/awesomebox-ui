class AwesomeboxUI.HeaderView extends Backbone.View
  template: @template('header')
  initialize: ->
    Spellbinder.initialize(@, replace: true)
    App.on('change:user', @render.bind(@))
  
  login: -> App.router.show_login()
  logout: -> App.logout()
  
  account: ->
    
  
  preferences: ->
    
