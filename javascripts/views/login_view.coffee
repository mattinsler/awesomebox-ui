class AwesomeboxUI.LoginView extends Backbone.View
  template: @template('login')
  initialize: -> Spellbinder.initialize(@, replace: true)
  
  show: ->
    $('body').append(@el)
    @$el.modal(keyboard: false)
    @$el.on 'hidden', => @remove()
  
  disable: ->
    @$('input').prop(disabled: true)
  
  enable: ->
    @$('input').prop(disabled: false)
  
  on_submit: (e) ->
    e.preventDefault()
    
    config = @$('form').serializeObject()
    @disable()
    
    App.login config, (err, user) =>
      return @$el.modal('hide') if user?
      
      @enable()
      @$('.alert').slideDown()
    
    false
