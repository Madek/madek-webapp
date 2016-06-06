React = require('react')
f = require('active-lodash')

module.exports = React.createClass
  displayName: 'ToggableLink'

  render: ({active} = @props)->

    onClick = if active then @props.onClick else null
    href = if active then @props.href else null

    style = if active then {} else {pointerEvents: 'none', cursor: 'default'}
    style = f.merge(@props.style, style)

    <a {...@props} onClick={onClick} style={style}>
      {@props.children}
    </a>
