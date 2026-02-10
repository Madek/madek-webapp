// A single icon (from styleguide) by name

import React from 'react'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import { omit } from '../../lib/utils.js'

// The following icons come from 'fontawesome' (all others from 'madek-icon-font'):
const FONT_AWESOME_ICONS = ['cloud', 'clock-o', 'flask']

const Icon = props => {
  const { i, ...restProps } = omit(props, ['mods'])
  const iconClass = FONT_AWESOME_ICONS.includes(i) ? `fa fa-${i}` : `icon-${i}`
  const classes = ui.cx(ui.parseMods(props), iconClass)

  return <i {...restProps} className={classes} />
}

Icon.propTypes = {
  i: PropTypes.string.isRequired
}

export default Icon
module.exports = Icon
