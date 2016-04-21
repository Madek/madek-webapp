Model = require('ampersand-model')
xhr = require('xhr')
f = require('active-lodash')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
RailsResource = require('./rails-resource-mixin.coffee')

# Base class for Restful Application Resources
module.exports = Model.extend RailsResource,
  type: 'AppResourceBase'
  idAttribute: 'url'
  typeAttribute: 'type' # see presenter{.rb,s/shared/app_resource.rb}
  props:
    url: 'string'
    uuid: 'string'

  save: (config)->
    Model::save.call @, {}, f.defaults({}, config, wait: true)

  # update props of type object, triggers 'change'
  merge: (prop, data)->
    @set(prop, f.merge(@get(prop), data))

  # shortcut, like presenter:
  dump: ()-> Model::serialize.call(@, arguments)

  # ajax helper
  _runRequest: (req, callback)->
    return xhr({
      method: req.method
      url: req.url
      body: req.body
      headers: {
        'Accept': 'application/json'
        'X-CSRF-Token': getRailsCSRFToken()}},
      (err, res, body)->
        data = (try JSON.parse(body)) or body
        callback(err, res, data))
