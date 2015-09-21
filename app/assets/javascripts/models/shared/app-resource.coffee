Model = require('ampersand-model')
defaults = require('lodash/object/defaults')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')

# Base class for Restful Application Resources
module.exports = Model.extend
  idAttribute: 'url'
  typeAttribute: '_type' # see presenters/shared/app_resource.rb
  props:
    url: 'string'

  ajaxConfig:
    headers:
      'Accept': 'application/json'
      'X-CSRF-Token': getRailsCSRFToken()

  save: (config)->
    Model::save.call @, {}, defaults({}, config, wait: true)
