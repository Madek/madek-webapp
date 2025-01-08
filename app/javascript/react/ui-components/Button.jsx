/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const ui = require('../lib/ui.js')

module.exports = React.createClass({
  displayName: 'Button',
  propTypes: {
    href: React.PropTypes.string,
    type: React.PropTypes.string,
    className: React.PropTypes.string,
    style: React.PropTypes.object,
    onClick: React.PropTypes.func,
    mod: React.PropTypes.oneOf(['primary', 'tertiary']),
    disabled: React.PropTypes.bool,
    children: React.PropTypes.node.isRequired
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
