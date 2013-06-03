class VersionRowView extends Backbone.View
  template: @template('app-version-row')
  initialize: -> Spellbinder.initialize(@)
  start_stop: ->
    if @model.get('running')
      @model.stop()
    else
      @model.start()
  
  open_remote: ->
    require('open')('http://' + _(@model.get('domains')).last()) if @model.get('running')


class AwesomeboxUI.AppView extends Backbone.View
  template: @template('app')
  events:
    'show a[data-toggle="tab"]': 'on_tab_show'
  initialize: ->
    Spellbinder.initialize(@)
    @versions = new AwesomeboxUI.VersionCollection()
    App.on('change:online', @render, @)
  
  render: ->
    @running_versions_view = new CollectionView(
      el: @$('.version-list.running')
      item_view: VersionRowView
      collection: @versions
      filter: (version) -> version.get('running')
    ).render()
    @not_running_versions_view = new CollectionView(
      el: @$('.version-list.not-running')
      item_view: VersionRowView
      collection: @versions
      filter: (version) -> !version.get('running')
    ).render()
    
    @versions.on 'change:running', =>
      @running_versions_view.render()
      @not_running_versions_view.render()
  
  start_stop: (e) ->
    if @model.is_running
      @model.stop()
    else
      @model.start()
  
  open_local_site: ->
    if @model.is_running
      require('open')("http://localhost:#{@model.proc_port}")
  
  open_folder: ->
    require('open')(@model.get('directory'))
  
  ship: ->
    
  
  on_tab_show: (e) ->
    method = 'on_show_' + $(e.target).attr('href').slice(1)
    @[method]?()
  
  on_show_versions: ->
    @model.versions (err, versions) =>
      @versions.set(versions) if versions?
