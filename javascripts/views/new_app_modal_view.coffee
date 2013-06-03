walkabout = require 'walkabout'
awesomebox = require 'awesomebox'

open_directory = (dir, callback) ->
  if typeof dir is 'function'
    callback = dir
    dir = process.cwd()
  
  $file = $('<input type="file" value="' + dir.toString() + '" nwdirectory />')
  $file.trigger('click')
  $file.change ->
    callback($file.val())
    $file = null

class AwesomeboxUI.NewAppModalView extends Backbone.View
  template: @template('new-app-modal')
  initialize: -> Spellbinder.initialize(@, replace: true)
  
  render: ->
    @templates = new Backbone.Collection([
      new Backbone.Model(
        id: 'bootstrap-example'
        name: 'Bootstrap Example'
        description: 'Simple Hello World app using Twitter Bootstrap'
        image: 'http://twitter.github.io/bootstrap/assets/img/examples/bootstrap-example-marketing.png'
      )
      new Backbone.Model(
        id: 'blank'
        name: 'Blank'
        description: 'Blank app'
        image: ''
        selected: true
      )
    ])
    new CollectionView(
      el: @$('.template-list')
      item_view: AwesomeboxUI.NewAppTemplateView
      collection: @templates
    ).render()
  
  show: ->
    @$('input[name="dir"]').val(walkabout().absolute_path)
    
    $('body').append(@el)
    @$el.modal()
    @$el.on 'hidden', => @remove()
  
  show_dir: ->
    open_directory @$('[name="dir"]').val(), (dir) =>
      @$('[name="dir"]').val(dir)
  
  show_errors: (errors) ->
    for k, v of errors
      @$('small.error[name="' + k + '"]').html(v).fadeIn()
  
  validate: (app) ->
    errors = {}
    
    if app.dir is ''
      errors.dir = 'is required'
    else
      app.dir = walkabout(app.dir)
      if dir.exists_sync()
        errors.dir = 'exists but is not an awesomebox app' unless dir.join('.awesomebox.json').exists_sync()
        try
          cfg = dir.join('.awesomebox.json').require()
          errors.dir = 'exists but is not an awesomebox app' unless cfg?.name?
        catch e
          errors.dir = 'exists but is not an awesomebox app'
    
    config = awesomebox.client_config
    if config.client_apps?
      # already exists
      return if dir.absolute_path in config.client_apps
    
    return null if Object.keys(errors).length is 0
    errors
  
  add_client_app: (path) ->
    config = awesomebox.client_config
    config.client_apps ?= []
    config.client_apps.push(path)
    awesomebox.client_config = config
  
  create_app_from_template: ->
    dir = @$('input[name="dir"]').val().trim()
    throw {dir: 'is required'} if dir is ''
    dir = walkabout(dir)
    throw {dir: 'cannot already exist'} if dir.exists_sync()
    
    template = @templates.where(selected: true)[0]
    throw {template: 'is required'} unless template?
    
    dir.mkdirp_sync()
    dir.join('.awesomebox.json').write_file_sync(JSON.stringify(
      name: dir.filename
    ))
    template_dir = walkabout('app-templates').join(template.id)
    template_dir.ls_sync(recursive: true).forEach (file) ->
      to_file = dir.join(file.absolute_path.slice(template_dir.absolute_path.length + 1))
      if file.is_directory_sync()
        to_file.mkdir_sync()
      else
        file.copy_sync(to_file)
    
    app = AwesomeboxUI.App.from_directory(dir)
    @add_client_app(app.get('directory'))
    App.apps.add(app)
    require('open')(app.get('directory'))
    @$el.modal('hide')
  
  create_app: ->
    type = @$('[name="type"] .active').val()
    # try
    switch type
      when 'new' then return @create_app_from_template()
    # catch errors
    #   console.log errors
    #   return @show_errors(errors)
    
    # create new app from template
    # create app from existing directory
    # open pre-existing app
    app = {
      dir: @$('input[name="dir"]').val().trim()
      template: @templates.where(selected: true)[0]
    }
    # errors = validate(app)
    
    # return @show_errors(errors) if errors?
    
    # config.client_apps ?= []
    # config.client_apps.push(dir.absolute_path)
    # awesomebox.client_config = config
    
    # walkabout(app.dir).mkdirp_sync()
    console.log 'copy ' + walkabout('app-templates').join(app.template.id).absolute_path + ' to ' + walkabout(app.dir).absolute_path
