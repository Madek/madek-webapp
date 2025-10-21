import React from 'react'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import { omit } from '../../lib/utils.js'

const Button = props => {
  const { href, onClick, type, mod, disabled, children, className, ...restProps } = props
  const cleanProps = omit(restProps, ['mod', 'mods'])
  const baseClass = className ? className : mod ? `${mod}-button` : 'button'
  const isDisabled = disabled || !(href || onClick || type)

  const classes = ui.cx({ disabled: isDisabled }, ui.parseMods(props), baseClass)

  // Determine element type and build appropriate props
  if (href || onClick) {
    return (
      <a {...cleanProps} href={href} onClick={onClick} className={classes}>
        {children}
      </a>
    )
  } else if (type) {
    return (
      <button {...cleanProps} type={type} onClick={onClick} className={classes}>
        {children}
      </button>
    )
  } else {
    return (
      <span {...cleanProps} className={classes}>
        {children}
      </span>
    )
  }
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
