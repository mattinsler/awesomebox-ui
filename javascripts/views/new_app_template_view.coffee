class AwesomeboxUI.NewAppTemplateView extends Backbone.View
  template: @template('new-app-template')
  initialize: -> Spellbinder.initialize(@, replace: true)
  events:
    'click *': 'select'
  
  select: ->
    @model.collection.where(selected: true).forEach (t) -> t.set(selected: false)
    @model.set(selected: true)
