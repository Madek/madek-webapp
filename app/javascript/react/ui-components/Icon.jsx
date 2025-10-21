// A single icon (from styleguide) by name

import React from 'react'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import { omit } from '../../lib/utils.js'

// The following icons come from 'fontawesome' (all others from 'madek-icon-font'):
const FONT_AWESOME_ICONS = ['cloud', 'clock-o', 'flask']
// Aliases
const ICON_NAME_ALIASES = {
  'madek-workflow': 'flask'
}

const Icon = props => {
  const { i, ...restProps } = omit(props, ['mods'])
  const iconName = ICON_NAME_ALIASES[i] || i
  const iconClass = FONT_AWESOME_ICONS.includes(iconName) ? `fa fa-${iconName}` : `icon-${iconName}`
  const classes = ui.cx(ui.parseMods(props), iconClass)

  return <i {...restProps} className={classes} />
}

Icon.propTypes = {
  i: PropTypes.string.isRequired
}

export default Icon
module.exports = Icon
