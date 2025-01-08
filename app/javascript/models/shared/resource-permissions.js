/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const AppResource = require('./app-resource.coffee');

// Base ResourcePermissions Model:
module.exports = AppResource.extend({
  type: 'ResourcePermissions',
  props: {
    permission_types: ['array'],
    responsible: ['object'],
    current_user: ['object'],
    current_user_permissions: ['array'],
    can_edit: ['boolean']
  },

  initialize(){
    AppResource.prototype.initialize.apply(this, arguments); // "super"

    // child collections don't propagate events by default, wire it up on creation:
    // NOTE: these are defined in classes that inherit from us
    return [this.user_permissions, this.group_permissions, this.api_client_permissions]
      .map(child=> {
        if ((child != null ? child.on : undefined) != null) {
          return this.listenTo(child, 'change add remove reset', e=> this.trigger('change'));
        }
    });
  }
});
