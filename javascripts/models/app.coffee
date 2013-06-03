{spawn} = require 'child_process'
walkabout = require 'walkabout'

AWESOMEBOX_PATH = walkabout('./node_modules/awesomebox/bin/awesomebox').absolute_path

class Expect
  constructor: (@stream) ->
    @matchers = []
    
    current_data = ''
    @on_data = (data) =>
      current_data += data.toString()
      for m in @matchers
        match = m.match(current_data)
        m.callback?(null, match.extracted, match.matched, current_data.slice(0)) if match?
  
  start: ->
    @stream.on('data', @on_data)
    @
  
  stop: ->
    @stream.removeListener('data', @on_data)
    @
  
  expect: (match, callback) ->
    if typeof match is 'string'
      @matchers.push(
        match: (haystack) ->
          idx = haystack.indexOf(match)
          return null if idx is -1
          a = haystack.slice(idx)
          {
            matched: a
            extracted: a
          }
        callback: callback
      )
    else if match instanceof RegExp
      @matchers.push(
        match: (haystack) ->
          m = match.exec(haystack)
          return null unless m?
          {
            matched: m[0]
            extracted: m[1]
          }
        callback: callback
      )
  

class AwesomeboxUI.App extends Backbone.Model
  @from_directory: (path) ->
    path = walkabout(path)
    try
      config = path.join('.awesomebox.json').require()
    catch err
      throw new Error('Could not find awesomebox configuration in ' + path.absolute_path)
    throw new Error('Not a valid awesomebox configuration') unless config?.name?
    config.directory = path.absolute_path
    new @(config)
  
  initialize: ->
    unless @id?
      if @has('_id')
        @id = @get('_id') 
        @unset('_id')
      else if @has('user')
        @id = "#{@get('user')}:#{@get('name')}"
      else
        @id = @get('name')
    
    @__defineGetter__ 'is_running', -> @proc?
    @__defineGetter__ 'is_local', -> @has('directory')
    @__defineGetter__ 'is_remote', -> @has('user')
    
    @set(is_running: @is_running)
    @set(is_local: @is_local)
    @set(is_remote: @is_remote)
    
    @on 'change:directory', => @set(is_local: @is_local)
    @on 'change:user', => @set(is_remote: @is_remote)
    
    @__defineGetter__ 'client', -> global.App.client?.app(@get('name'))
  
  start: ->
    return if @proc?
    
    @proc = spawn(AWESOMEBOX_PATH, ['run'],
      cwd: @get('directory')
    )
    @set(is_running: true)
    on_exit = => @proc?.kill()
    process.on('exit', on_exit)
    @proc.on 'close', ->
      process.removeListener('exit', on_exit)
    
    expecter = new Expect(@proc.stdout).start()
    expecter.expect /Listening on port ([0-9]+)/, (err, port) =>
      @proc_port = parseInt(port)
      expecter.stop()
    
    @proc.on 'close', (code) =>
      expecter.stop()
      delete @proc
      @set(is_running: false)
  
  stop: ->
    return unless @proc?
    
    @proc.kill()
  
  versions: (callback) ->
    client = @client
    return callback(new Error('Not logged in')) unless @client?
    client.versions.list(callback)
