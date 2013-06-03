require('./lib/extend_jquery')(window.$)

_ = global._ = window._ = require 'underscore'
Backbone = global.Backbone = window.Backbone = require 'backbone'
Backbone.$ = global.$ =  window.$

global.moment = window.moment = require 'moment'
global.CollectionView = window.CollectionView = require('./lib/collection_view').CollectionView
global.Spellbinder = window.Spellbinder = require('../components/spellbinder/dist/spellbinder').Spellbinder

ejs = require 'ejs'
walkabout = require 'walkabout'
gui = window.require 'nw.gui'

awesomebox = require 'awesomebox'
AwesomeboxClient = require 'awesomebox.node'

Backbone.View.template = (name) ->
  content = walkabout('templates').join(name + '.html').read_file_sync('utf8')
  ejs.compile(content)


class Clock extends Backbone.Model
  initialize: (@intervals = []) ->
    @set(time: new Date(), false)
    setInterval(@update.bind(@), 1000)

  update: ->
    time = new Date()
    secs = parseInt(time.getTime() / 1000)
    @set(time: time)
    for i in @intervals
      @set('every_' + i + '_sec': time) if secs % i
  
  now: ->
    @get('time')

  now_m: ->
    moment(@now())
  

class AwesomeboxUI extends Backbone.Model
  initialize: ->
    [].concat(
      walkabout('javascripts/models').readdir_sync()
      walkabout('javascripts/collections').readdir_sync()
      walkabout('javascripts/views').readdir_sync()
    ).forEach (file) -> require(file.absolute_path)
    
    @set(online: false)
    @apps = new AwesomeboxUI.AppCollection()
    @clock = new Clock([10, 30])
    
  start: ->
    {Router} = require './router'
    @router = new Router()
    
    $('body').hide()
    @login (err, user) ->      
      gui.Window.get().show()
      $('body').fadeIn()
  
  login: (config, callback) ->
    if typeof config is 'function'
      callback = config
      config = null
    
    config ?= awesomebox.client_config
    client = new AwesomeboxClient(config)
    client.user.get (err, user) =>
      return callback?(err) if err?
      return callback?() unless user?
      
      cfg = awesomebox.client_config
      cfg.api_key = user.api_key
      awesomebox.client_config = cfg
      
      user = new AwesomeboxUI.User(user)
      @client = new AwesomeboxClient(cfg)
      @set(
        user: user
        online: true
      )
      callback?(null, user)
  
  logout: ->
    cfg = awesomebox.client_config
    delete cfg.api_key
    awesomebox.client_config = cfg
    @unset('user')
    @set(online: false)

global.AwesomeboxUI = window.AwesomeboxUI = AwesomeboxUI
