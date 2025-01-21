/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import ui from '../lib/ui.js'

module.exports = createReactClass({
  displayName: 'Link',
  propTypes: {
    href: PropTypes.string,
    onClick: PropTypes.func,
    children: PropTypes.node,
    disabled: PropTypes.bool
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { href, onClick, children } = param
    const restProps = f.omit(this.props, ['mods'])
    const isLink = href || onClick ? true : undefined
    const className = ui.cx({ link: isLink }, ui.parseMods(this.props), 'ui-link')

    // force disabled if no interaction:
    const isDisabled = !isLink ? true : this.props.disabled

    return (
      <a {...Object.assign({}, restProps, { className: className, disabled: isDisabled })}>
        {children}
      </a>
    )
  }
})
