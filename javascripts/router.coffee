class exports.Router extends Backbone.Model
  initialize: ->
    new AwesomeboxUI.DrawerView(el: '#drawer').render()
    new AwesomeboxUI.HeaderView(el: '#header').render()
    
    @$content = $('#content')
    
    App.apps.fetch()
    App.on 'change:user', ->
      App.apps.fetch()
  
  show_login: ->
    new AwesomeboxUI.LoginView().render().show()
  
  show_app: (app) ->
    new AwesomeboxUI.AppView(el: @$content, model: app).render()
    @set(app: app)
