/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import ui from '../lib/ui.js'

module.exports = createReactClass({
  displayName: 'Button',
  propTypes: {
    href: PropTypes.string,
    type: PropTypes.string,
    className: PropTypes.string,
    style: PropTypes.object,
    onClick: PropTypes.func,
    mod: PropTypes.oneOf(['primary', 'tertiary']),
    disabled: PropTypes.bool,
    children: PropTypes.node.isRequired
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    let { href, onClick, type, mod, disabled, children, className } = param
    const restProps = f.omit(this.props, ['mod', 'mods'])
    const baseClass = className ? className : mod ? `${mod}-button` : 'button'
    if (!(href || onClick || type)) {
      disabled = true
    } // force disabled if no target

    const classes = ui.cx({ disabled }, ui.parseMods(this.props), baseClass)
    const Elm = (() => {
      switch (
        false // NOTE: try avoiding 'button' because styling…
      ) {
        case !href && !onClick:
          return 'a'
        case !type:
          return 'button'
        default:
          return 'span'
      }
    })()

    return <Elm {...Object.assign({}, restProps, { className: classes })}>{children}</Elm>
  }
})
