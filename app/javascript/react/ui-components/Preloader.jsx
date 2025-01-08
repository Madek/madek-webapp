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
  displayName: 'Preloader',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { mods } = param
    const restProps = f.omit(this.props, ['mods'])
    return (
      <div
        {...Object.assign({}, restProps, {
          className: ui.cx(ui.parseMods(this.props), 'ui-preloader')
        })}
      />
    )
  }
})
