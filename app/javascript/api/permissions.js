import { compact, every, first, flatten, groupBy, map, mapValues, uniq } from 'lodash-es'
import getRailsCSRFToken from '../lib/rails-csrf-token.js'

const PERMISSION_KEYS = [
  'public_permission',
  'user_permissions',
  'group_permissions',
  'api_client_permissions'
]

// Aggregates an array of per-resource permissions into a single batch state object,
// computing 'mixed' trilean values where resources differ.
export function buildBatchPermissionsState(batchData) {
  const allPerms = batchData.batch_permissions
  const permissionTypes = uniq(flatten(map(allPerms, 'permission_types')))
  const type = allPerms[0] && allPerms[0].type

  const aggregated = {}
  PERMISSION_KEYS.forEach(key => {
    const isModel = key === 'public_permission'
    const permsForType = flatten(map(allPerms, key))
    const permsBySubject = groupBy(permsForType, 'subject.uuid')

    const batchPerms = map(permsBySubject, perms => {
      const combined = Object.fromEntries(
        map(permissionTypes, permKey => {
          const hasForAll = allPerms.length === perms.length
          const allEqual = every(map(perms, permKey), b => b === first(perms)[permKey])
          return [permKey, !hasForAll || !allEqual ? 'mixed' : first(perms)[permKey]]
        })
      )
      return {
        ...combined,
        subject: first(perms).subject,
        tooltip_text: isModel ? first(perms).tooltip_text : null
      }
    })

    aggregated[key] = isModel ? batchPerms[0] || {} : batchPerms
  })

  return {
    type,
    can_edit: true,
    permission_types: permissionTypes,
    batchResourceIds: map(allPerms, 'uuid'),
    ...aggregated
  }
}

// Serializes batch permissions state into the format the Rails batch API expects.
export function serializeBatchPermissions(state) {
  const permissions = Object.fromEntries(
    PERMISSION_KEYS.map(key => {
      const isModel = key === 'public_permission'
      const list = isModel ? [state[key]] : state[key]
      const cleaned = compact(
        map(list, perm => {
          const perms = mapValues(perm, v => (v === 'mixed' ? undefined : v))
          return isModel ? perms : { ...perms, subject: perm.subject && perm.subject.uuid }
        })
      )
      return [key, isModel ? first(cleaned) : cleaned]
    })
  )
  return { resource_ids: state.batchResourceIds, permissions }
}

export async function saveBatchPermissions(state, saveAction, returnTo) {
  const body = { ...serializeBatchPermissions(state), return_to: returnTo }
  const res = await fetch(saveAction.url, {
    method: saveAction.method,
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      'X-CSRF-Token': getRailsCSRFToken()
    },
    body: JSON.stringify(body)
  })

  if (!res.ok) {
    let err
    try {
      err = await res.json()
    } catch {
      err = res.statusText
    }
    throw err
  }

  return res.json()
}

// Computes the cascade effect when a trilean permission changes:
// checking a permission also checks all weaker (preceding) ones,
// unchecking also unchecks all stronger (following) ones.
export function applyPermissionCascade(permission, permissionTypes, name, value) {
  const updated = { ...permission, [name]: value }
  const nameIndex = permissionTypes.indexOf(name)

  permissionTypes.forEach((pt, i) => {
    if (pt === name || permission[pt] == null) return
    if (value === true && i < nameIndex) updated[pt] = true
    if (value === false && i > nameIndex) updated[pt] = false
  })

  return updated
}

export async function savePermissions(data) {
  const resourceKey = data.type === 'Collection' ? 'collection' : 'media_entry'
  const res = await fetch(data.url, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      'X-CSRF-Token': getRailsCSRFToken()
    },
    body: JSON.stringify({ [resourceKey]: data })
  })

  if (!res.ok) {
    let err
    try {
      err = await res.json()
    } catch {
      err = res.statusText
    }
    throw err
  }

  return res.json()
}
