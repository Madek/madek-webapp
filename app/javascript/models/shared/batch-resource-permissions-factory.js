import { every, compact, extend, first, flatten, groupBy, map, mapValues, uniq } from 'lodash-es';
import AppResource from '../shared/app-resource.js'

const PERMISSIONS = [
  ['public_permission', 'model'],
  ['user_permissions', 'collection'],
  ['group_permissions', 'collection'],
  ['api_client_permissions', 'collection']
]

export default function (name, baseModel) {
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
      const permissionTypes = uniq(flatten(map(allPerms, 'permission_types')))

      PERMISSIONS.forEach((...args) => {
        const [permissionName, modelType] = Array.from(args[0])
        const permsForType = flatten(map(allPerms, permissionName))
        const permsBySubject = groupBy(permsForType, 'subject.uuid')

        const batchPerms = map(permsBySubject, function (perms) {
          const combinedPerms = Object.fromEntries(
            map(permissionTypes, function (key) {
              // its mixed when not all perms for all resources are equal
              const hasPermsForAll = allPerms.length === perms.length
              const allEqual = every(map(perms, key), b => b === first(perms)[key])
              const isMixed = !hasPermsForAll || !allEqual
              return [key, isMixed ? 'mixed' : first(perms)[key]];
            })
          )
          return extend(combinedPerms, {
            subject: first(perms).subject,
            tooltip_text:
              permissionName === 'public_permission' ? first(perms).tooltip_text : null
          });
        })
        // NOTE: tooltip for other permissions comes with the subject

        return this[permissionName].set(modelType === 'model' ? batchPerms[0] : batchPerms)
      })
      this.set('permission_types', permissionTypes)
      this.set('batchResources', props.batch_resources.resources)
      this.set('batchResourceIds', map(props.batch_permissions, 'uuid'))
    },

    // custom serialize to match what rails expects — used on this.save()
    serialize() {
      const data = AppResource.prototype.serialize.call(this)
      const permissionSubjects = map(PERMISSIONS, first)
      return {
        resource_ids: this.batchResourceIds,
        permissions: Object.fromEntries(
          map(permissionSubjects, function (key) {
            let list = key === 'public_permission' ? [data[key]] : data[key]
            list = compact(
              map(list, function (permissions) {
                // cleanup mixed:
                const perms = mapValues(permissions, function (permission) {
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
                  return extend(perms, { subject: permissions.subject.uuid });
                }
              })
            )

            return [key, key === 'public_permission' ? first(list) : list];
          })
        )
      };
    }
  });
}
