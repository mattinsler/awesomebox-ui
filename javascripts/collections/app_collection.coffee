_ = require 'underscore'
async = require 'async'
awesomebox = require 'awesomebox'
walkabout = require 'walkabout'

read_local = (callback) ->
  async.map (awesomebox.client_config.client_apps ? []), (app_path, cb) ->
    try
      cb(null, AwesomeboxUI.App.from_directory(app_path))
    catch err
      cb()
  , (err, apps) ->
    return callback(err) if err?
    callback(null, _(apps).compact())

read_remote = (callback) ->
  return callback(null, []) unless App.client?
  App.client.apps.list(callback)

class AwesomeboxUI.AppCollection extends Backbone.Collection
  model: AwesomeboxUI.App
  
  sync: (method, collection, options) ->
    if method is 'read'
      async.parallel
        local: read_local
        remote: read_remote
      , (err, data) ->
        return options.error(err) if err?
        
        apps = _(data.local).inject (o, app) ->
          o[app.id] = app
          o
        , {}
        
        for app in data.remote
          app = new AwesomeboxUI.App(app) unless app instanceof AwesomeboxUI.App
          if apps[app.id]?
            apps[app.id].set(app)
          else
            apps[app.id] = app
        
        options.success(_(apps).values())
