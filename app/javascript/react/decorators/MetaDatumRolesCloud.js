import React from 'react'
import PropTypes from 'prop-types'
import setUrlParams from '../../lib/set-params-for-url.js'
import cx from 'classnames'

/*
Group in the following way: [p1, p1, p2, p1] -> [p1, p2, p1]
*/
function groupContiguous(list) {
  return list.reduce((acc, currentItem) => {
    const { uuid, label, url, role } = currentItem
    const person = acc.slice(-1)[0]
    if (person && person.uuid === uuid) {
      return [
        ...acc.slice(0, -1),
        { ...person, roles: role ? [...person.roles, role] : person.roles }
      ]
    } else {
      return [...acc, { uuid, label, url, roles: role ? [role] : [] }]
    }
  }, [])
}

export default function MetaDatumRolesCloud({ personRoleTuples, metaKeyId }) {
  const persons = groupContiguous(personRoleTuples)
  const anyRolePresent = persons.some(p => p.roles.length > 0)
  return (
    <div className="small ui-tag-cloud">
      {persons.map(({ label, url, roles }, i) => {
        return (
          <div
            key={i}
            className={cx('ui-tag-cloud-item', {
              'ui-tag-cloud-person-roles-item block clearfix': anyRolePresent
            })}>
            <a href={url} className="link ui-tag-button ui-link">
              {label}
            </a>
            {roles.length > 0 && (
              <div className="ui-role-tags">
                <span>:</span>
                {roles.map(({ label: roleLabel, id }, i) => {
                  var rolesUrl = setUrlParams(url, {
                    list: {
                      show_filter: true,
                      filter: JSON.stringify({ meta_data: [{ key: metaKeyId, value: id }] })
                    }
                  })
                  return (
                    <a
                      key={i}
                      href={rolesUrl}
                      className="link ui-tag-button ui-link"
                      title={`${label}: ${roleLabel}`}>
                      {roleLabel}
                    </a>
                  )
                })}
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}

MetaDatumRolesCloud.propTypes = {
  personRoleTuples: PropTypes.arrayOf(
    PropTypes.shape({
      uuid: PropTypes.string.isRequired,
      label: PropTypes.string.isRequired,
      url: PropTypes.string.isRequired,
      role: PropTypes.shape({
        label: PropTypes.string.isRequired
      })
    })
  ),
  metaKeyId: PropTypes.string.isRequired
}
