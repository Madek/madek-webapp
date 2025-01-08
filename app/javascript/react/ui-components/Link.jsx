/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const ui = require('../lib/ui.js')

module.exports = React.createClass({
  displayName: 'Link',
  propTypes: {
    href: React.PropTypes.string,
    onClick: React.PropTypes.func,
    children: React.PropTypes.node,
    disabled: React.PropTypes.bool
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
