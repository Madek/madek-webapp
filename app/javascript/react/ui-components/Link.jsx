import React from 'react'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import { omit } from '../../lib/utils.js'

const Link = props => {
  const { href, onClick, children, disabled } = props
  const restProps = omit(props, ['mods'])
  const isLink = !!(href || onClick)
  const className = ui.cx({ link: isLink }, ui.parseMods(props), 'ui-link')

  // force disabled if no interaction:
  const isDisabled = !isLink ? true : disabled

  return (
    <a {...restProps} className={className} disabled={isDisabled}>
      {children}
    </a>
  )
}

Link.propTypes = {
  href: PropTypes.string,
  onClick: PropTypes.func,
  children: PropTypes.node,
  disabled: PropTypes.bool
}

export default Link
module.exports = Link
