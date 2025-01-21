/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// A single icon (from styleguide) by name

import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import ui from '../lib/ui.js'

// The following icons come from 'fontawesome' (all others from 'madek-icon-font'):
const FONT_AWESOME_ICONS = ['cloud', 'clock-o', 'flask']
// Aliases
const ICON_NAME_ALIASES = {
  'madek-workflow': 'flask'
}

module.exports = createReactClass({
  displayName: 'Icon',
  propTypes: {
    i: PropTypes.string.isRequired
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    let { i } = param
    const restProps = f.omit(this.props, ['i', 'mods'])
    i = ICON_NAME_ALIASES[i] || i
    const iconClass = f.includes(FONT_AWESOME_ICONS, i) ? `fa fa-${i}` : `icon-${i}`
    const classes = ui.cx(ui.parseMods(this.props), iconClass)

    return <i {...Object.assign({}, restProps, { className: classes })} />
  }
})
