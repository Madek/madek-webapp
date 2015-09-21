AppResource = require('./app-resource.coffee')

# Base ResourcePermissions Model:
module.exports = AppResource.extend
  props:
    permission_types: ['array']
    responsible: ['object']
    current_user: ['object']
    current_user_permissions: ['array']
    can_edit: ['boolean']

  initialize: ()->
    # child collections don't propate events by default, wire it up on creation:
    # NOTE: these are defined in classes that inherit from us
    [@user_permissions, @group_permissions, @api_client_permissions]
      .map (child)=>
        if child?.on?
          @.listenTo child, 'change add remove reset', (e)=> @trigger('change')
