/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'active-lodash'
import AppResource from '../shared/app-resource.js'

const PERMISSIONS = [
  ['public_permission', 'model'],
  ['user_permissions', 'collection'],
  ['group_permissions', 'collection'],
  ['api_client_permissions', 'collection']
]

module.exports = function (name, baseModel) {
  return baseModel.extend({
    type: name,

    props: {
      batchResourceIds: 'array', // complete list of ids for submitting
      batchResources: 'array', // for overview box (can be trimmed!)
      return_to: 'string'
    },

    // handle data coming from presenters:
    // - create fresh instances of nested models (based on list of data)
    // - 1 model per *unique* subject (public always singular!)
    // - also extract permission types and list of resources
    initialize(props) {
      baseModel.prototype.initialize.apply(this, arguments) // "super"
      const allPerms = props.batch_permissions
      const permissionTypes = f.uniq(f.flatten(f.map(allPerms, 'permission_types')))

      PERMISSIONS.forEach((...args) => {
        const [permissionName, modelType] = Array.from(args[0])
        const permsForType = f.flatten(f.map(allPerms, permissionName))
        const permsBySubject = f.groupBy(permsForType, 'subject.uuid')

        const batchPerms = f.map(permsBySubject, function (perms) {
          const combinedPerms = f.object(
            f.map(permissionTypes, function (key) {
              // its mixed when not all perms for all resources are equal
              const hasPermsForAll = allPerms.length === perms.length
              const allEqual = f.all(f.map(perms, key), b => b === f.first(perms)[key])
              const isMixed = !hasPermsForAll || !allEqual
              return [key, isMixed ? 'mixed' : f.first(perms)[key]]
            })
          )
          return f.extend(combinedPerms, {
            subject: f.first(perms).subject,
            tooltip_text:
              permissionName === 'public_permission' ? f.first(perms).tooltip_text : null
          })
        })
        // NOTE: tooltip for other permissions comes with the subject

        return this[permissionName].set(modelType === 'model' ? batchPerms[0] : batchPerms)
      })
      this.set('permission_types', permissionTypes)
      this.set('batchResources', props.batch_resources.resources)
      this.set('batchResourceIds', f.map(props.batch_permissions, 'uuid'))
    },

    // custom serialize to match what rails expects — used on this.save()
    serialize() {
      const data = AppResource.prototype.serialize.call(this)
      const permissionSubjects = f.map(PERMISSIONS, f.first)
      return {
        resource_ids: this.batchResourceIds,
        permissions: f.object(
          f.map(permissionSubjects, function (key) {
            let list = key === 'public_permission' ? [data[key]] : data[key]
            list = f.compact(
              f.map(list, function (permissions) {
                // cleanup mixed:
                const perms = f.mapValues(permissions, function (permission) {
                  if (permission === 'mixed') {
                    return undefined
                  } else {
                    return permission
                  }
                })
                // cleanup subjects:
                if (key === 'public_permission') {
                  return perms
                } else {
                  return f.extend(perms, { subject: permissions.subject.uuid })
                }
              })
            )

            return [key, key === 'public_permission' ? f.first(list) : list]
          })
        )
      }
    }
  })
}
