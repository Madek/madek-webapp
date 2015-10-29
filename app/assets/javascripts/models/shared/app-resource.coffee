Model = require('ampersand-model')
defaults = require('active-lodash').defaults
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

  # update props of type object, triggers 'change'
  merge: (prop, data)->
    @set(prop, f.merge(@get(prop), data))

  # shortcut, like presenter:
  dump: ()-> Model::serialize.call(@, arguments)
