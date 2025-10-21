import React from 'react'
import cx from 'classnames'

const ExploreMenuEntry = ({ label, hrefUrl, active }) => {
  return (
    <ul className="ui-side-navigation-lvl2">
      <li className={cx('ui-side-navigation-lvl2-item', { active: active })}>
        <a className="weak" href={hrefUrl}>
          {label}
        </a>
      </li>
    </ul>
  )
}

export default ExploreMenuEntry
module.exports = ExploreMenuEntry
