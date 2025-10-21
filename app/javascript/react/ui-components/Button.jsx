import React from 'react'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import { omit } from '../../lib/utils.js'

const Button = ({ href, onClick, type, mod, disabled, children, className, ...restProps }) => {
  const cleanProps = omit(restProps, ['mod', 'mods'])
  const baseClass = className ? className : mod ? `${mod}-button` : 'button'
  const isDisabled = disabled || !(href || onClick || type)

  const classes = ui.cx({ disabled: isDisabled }, ui.parseMods(restProps), baseClass)

  // Determine element type
  let Elm = 'span'
  if (href || onClick) {
    Elm = 'a'
  } else if (type) {
    Elm = 'button'
  }

  return (
    <Elm {...cleanProps} className={classes}>
      {children}
    </Elm>
  )
}

Button.propTypes = {
  href: PropTypes.string,
  type: PropTypes.string,
  className: PropTypes.string,
  style: PropTypes.object,
  onClick: PropTypes.func,
  mod: PropTypes.oneOf(['primary', 'tertiary']),
  disabled: PropTypes.bool,
  children: PropTypes.node.isRequired
}

export default Button
module.exports = Button
