import React from 'react'
import { omit } from '../../lib/utils.js'

const ToggableLink = props => {
  const { active, children, style: propStyle, onClick: propOnClick } = props
  const restProps = omit(props, ['active'])
  const onClick = active ? propOnClick : null

  const inactiveStyle = active ? {} : { pointerEvents: 'none', cursor: 'default' }
  const style = { ...propStyle, ...inactiveStyle }

  return (
    <a {...restProps} onClick={onClick} style={style}>
      {children}
    </a>
  )
}

export default ToggableLink
module.exports = ToggableLink
