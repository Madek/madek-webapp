/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import cx from 'classnames'

module.exports = createReactClass({
  displayName: 'ExploreMenuEntry',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { label, hrefUrl, active } = param
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
})
