class AwesomeboxUI.User extends Backbone.Model
  initialize: ->
    hash = require('crypto').createHash('md5')
    hash.update(@get('email').toLowerCase())
    @set(gravatar_hash: hash.digest('hex'))
