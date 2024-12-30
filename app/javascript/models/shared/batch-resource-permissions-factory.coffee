f = require('active-lodash')
AppResource = require('../shared/app-resource.coffee')


PERMISSIONS = [
  ['public_permission', 'model'],
  ['user_permissions', 'collection'],
  ['group_permissions', 'collection'],
  ['api_client_permissions', 'collection']
]

module.exports = (name, baseModel)-> baseModel.extend({
  type: name

  props:
    # batch_permissions: 'array' # initial "raw" data, not needed

    batchResources: 'array' # for overview box as well as submitting

    return_to: 'string'

  # handle data coming from presenters:
  # - create fresh instances of nested models (based on list of data)
  # - 1 model per *unique* subject (public always singular!)
  # - also extract permission types and list of resources
  initialize: (props)->
    baseModel::initialize.apply(@, arguments) # "super"
    allPerms = props.batch_permissions
    permissionTypes = f.uniq(f.flatten(f.map(allPerms, 'permission_types')))

    PERMISSIONS.forEach(([permissionName, modelType])=>
      permsForType = f.flatten(f.map(allPerms, (permissionName)))
      permsBySubject = f.groupBy(permsForType, 'subject.uuid')

      batchPerms = f.map(permsBySubject, (perms, uuid)->
        combinedPerms = f.object(f.map(permissionTypes, (key)->
          # its mixed when not all perms for all resources are equal
          hasPermsForAll = allPerms.length == perms.length
          allEqual = f.all(f.map(perms, key), (b)-> b == f.first(perms)[key])
          isMixed = !hasPermsForAll or !allEqual
          [key, if isMixed then 'mixed' else f.first(perms)[key]]
        ))
        f.extend(combinedPerms, {subject: f.first(perms).subject})
      )
      @[permissionName].set(
        if modelType == 'model' then batchPerms[0] else batchPerms)
    )
    @set('permission_types', permissionTypes)
    @set('batchResources', props.batch_resources.resources)

  # custom serialize to match what rails expects — used on this.save()
  serialize: () ->
    data = AppResource::serialize.call(this)
    permissionSubjects = f.map(PERMISSIONS, f.first)
    {
      resource_ids: f.map(@batchResources, 'uuid'),
      permissions: f.object(f.map(permissionSubjects, (key) ->
        list = if key == 'public_permission' then [data[key]] else data[key]
        list = f.compact f.map list, (permissions) ->
          # cleanup mixed:
          perms = f.mapValues permissions, (permission)->
            if permission is 'mixed' then undefined else permission
          # cleanup subjects:
          if key == 'public_permission'
            perms
          else
            f.extend(perms, {subject: permissions.subject.uuid})

        [key, if key == 'public_permission' then f.first(list) else list]))
    }
})
