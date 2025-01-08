Model = require('ampersand-model')
xhr = require('xhr')
f = require('active-lodash')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
RailsResource = require('./rails-resource-mixin.coffee')

customDataTypes =
  # tri-state, can be true, false or 'mixed'
  trilean: {
    compare: (a, b)-> a == b
    set: (newVal)->
      if f.includes([true, false, 'mixed'], newVal)
        {val: newVal, type: 'trilean'}
      else
        {val: newVal, type: "'#{newVal}' (#{typeof newVal})"}
  }

# Base class for Restful Application Resources
module.exports = Model.extend RailsResource,
  type: 'AppResource'
  idAttribute: 'url'
  typeAttribute: 'type' # see presenter{.rb,s/shared/app_resource.rb}
  dataTypes: customDataTypes
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
      beforeSend: req.beforeSend
      headers: {
        'Accept': 'application/json'
        'X-CSRF-Token': getRailsCSRFToken()}},
      (err, res, body)->
        data = (try JSON.parse(body)) or body
        callback(err, res, data))
