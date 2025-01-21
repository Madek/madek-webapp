/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import ui from '../lib/ui.js'

module.exports = createReactClass({
  displayName: 'Preloader',

  render() {
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
