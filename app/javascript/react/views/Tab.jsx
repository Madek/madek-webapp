/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import cx from 'classnames'

module.exports = createReactClass({
  displayName: 'Tab',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { privacyStatus, label, href, iconType, active } = param
    const classes = cx({ active }, 'ui-tabs-item')
    const icon = (() => {
      if (iconType === 'privacy_status_icon') {
        if (privacyStatus) {
          const icon_map = {
            public: 'open',
            shared: 'group',
            private: 'private'
          }
          return <i className={`icon-privacy-${icon_map[privacyStatus]}`} />
        }
      }
    })()

    return (
      <li className={classes} data-test-id={this.props.testId}>
        <a href={href} onClick={this.props.onClick}>
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
})
