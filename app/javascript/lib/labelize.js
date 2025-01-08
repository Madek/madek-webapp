import React from 'react'
import f from 'lodash'
import resourceName from '../react/lib/decorate-resource-names.js'

const labelize = (resourceList, { withLink = false, onDelete, creatorId = null } = {}) => {
  function canDelete(resource) {
    if(!creatorId) return true
    return resource.uuid !== creatorId
  }

  function mod(resource) {
    return prepareType(resource).type.toLowerCase()
  }

  function prepareType(resource) {
    if (resource.type && /Group/.test(resource.type)) {
      resource.type = resource.type.replace(/.*Group/, 'Group')
    }
    return resource
  }

  return f.map(f.compact(resourceList), (resource, i) => ({
    key: `${resource.uuid}-${i}`,
    href: withLink ? resource.url : undefined,
    mod: mod(resource),
    mods: 'not-interactive',
    tag: 'span',
    children: (
      <span>
        {resourceName(prepareType(resource))}
        {!!onDelete && canDelete(resource) && (
          <button
            className="multi-select-tag-remove"
            style={{ background: 'transparent' }}
            onClick={ev => {
              ev.preventDefault(), onDelete(resource)
            }}>
            <i className="icon-close"></i>
          </button>
        )}
      </span>
    )
  }))
}

export default labelize
