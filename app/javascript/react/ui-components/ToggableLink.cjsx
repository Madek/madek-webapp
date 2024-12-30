React = require('react')
f = require('active-lodash')

module.exports = React.createClass
  displayName: 'ToggableLink'

  render: ({active} = @props)->
    restProps = f.omit(@props, ['active'])
    onClick = if active then @props.onClick else null
    href = if active then @props.href else null

    style = if active then {} else {pointerEvents: 'none', cursor: 'default'}
    style = f.merge(@props.style, style)

    <a {...restProps} onClick={onClick} style={style}>
      {@props.children}
    </a>
