class AppItemView extends Backbone.View
  template: @template('drawer-app')
  initialize: ->
    Spellbinder.initialize(@, replace: true)
    App.on 'change:app', (src, app) =>
      @$el.toggleClass('sidebar-selected', @model is app)
  
  select: ->
    App.router.show_app(@model)

class AwesomeboxUI.DrawerView extends Backbone.View
  template: @template('drawer')
  initialize: ->
    Spellbinder.initialize(@, replace: true)
  
  new_app: ->
    new AwesomeboxUI.NewAppModalView().render().show()
  
  render: ->
    @shipped_apps = new CollectionView(
      el: @$('.shipped-apps')
      item_view: AppItemView
      collection: App.apps
      filter: (app) -> app.get('is_remote')
    ).render()
    @local_apps = new CollectionView(
      el: @$('.local-apps')
      item_view: AppItemView
      collection: App.apps
      filter: (app) -> app.get('is_local')
    ).render()
    
    App.apps.on 'change:is_local', =>
      @shipped_apps.render()
      @local_apps.render()
    App.apps.on 'change:is_remote', =>
      @shipped_apps.render()
      @local_apps.render()
