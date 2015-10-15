Model = require('ampersand-model')
defaults = require('lodash/object/defaults')
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
    Model::save.call @, {}, defaults({}, config, wait: true)

  # shortcut, like presenter:
  dump: ()-> Model::serialize.call(@, arguments)
