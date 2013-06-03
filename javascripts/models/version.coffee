class AwesomeboxUI.Version extends Backbone.Model
  initialize: ->
    @id = @get('instance').version_name
    
    @__defineGetter__ 'client', -> global.App.client?.app(@get('instance').app).version(@get('instance').version_name)

  start: ->
    @client?.start (err, data) =>
      @set(data) if data?
  
  stop: ->
    @client?.stop (err, data) =>
      @set(data) if data?
  
  refresh: ->
    @client?.status (err, data) =>
      @set(data) if data?
