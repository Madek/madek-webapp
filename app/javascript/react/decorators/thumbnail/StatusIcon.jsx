import React from 'react'
import Icon from '../../ui-components/Icon.jsx'

const StatusIcon = ({ privacyStatus, iconClass }) => {
  // map the type name:
  // type = get.type.replace(/Collection/, 'MediaSet')

  // map the privacy icon:
  // see <http://madek.readthedocs.org/en/latest/entities/#privacy-status>
  // vs <http://test.madek.zhdk.ch/styleguide/Icons#6.2>

  const iconMapping = { public: 'open', private: 'private', shared: 'group' }
  const iconName = `privacy-${iconMapping[privacyStatus]}`

  return <Icon i={iconName} title={privacyStatus} className={iconClass} />
}

export default StatusIcon
module.exports = StatusIcon
