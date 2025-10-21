import React from 'react'
import cx from 'classnames'

const Tab = ({ privacyStatus, label, href, iconType, active, testId, onClick }) => {
  const classes = cx({ active }, 'ui-tabs-item')

  let icon
  if (iconType === 'privacy_status_icon' && privacyStatus) {
    const icon_map = {
      public: 'open',
      shared: 'group',
      private: 'private'
    }
    icon = <i className={`icon-privacy-${icon_map[privacyStatus]}`} />
  }

  return (
    <li className={classes} data-test-id={testId}>
      <a href={href} onClick={onClick}>
        {icon ? (
          <span>
            {icon} {label}
          </span>
        ) : (
          label
        )}
      </a>
    </li>
  )
}

export default Tab
module.exports = Tab
