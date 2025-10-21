import React from 'react'
import ui from '../lib/ui.js'
import { omit } from '../../lib/utils.js'

const Preloader = props => {
  const restProps = omit(props, ['mods'])
  return <div {...restProps} className={ui.cx(ui.parseMods(props), 'ui-preloader')} />
}

export default Preloader
module.exports = Preloader
