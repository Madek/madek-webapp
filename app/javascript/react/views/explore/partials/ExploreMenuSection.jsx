import React from 'react'
import cx from 'classnames'

const ExploreMenuSection = ({ label, hrefUrl, active, children }) => {
  return (
    <li className={cx('ui-side-navigation-item', { active: active })}>
      <a className="strong" href={hrefUrl}>
        {label}
      </a>
      {children}
    </li>
  )
}

export default ExploreMenuSection
module.exports = ExploreMenuSection
