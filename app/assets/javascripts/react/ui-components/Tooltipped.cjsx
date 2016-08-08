# Wrap this around anything for bootstrap-style tooltips

React = require('react')
Tooltip = require('react-bootstrap/lib/Tooltip')
OverlayTrigger = require('react-bootstrap/lib/OverlayTrigger')

module.exports = React.createClass
  displayName: 'Tooltipped'
  propTypes:
    text: React.PropTypes.string.isRequired
    id: React.PropTypes.string.isRequired
    children: React.PropTypes.node.isRequired

  render: ({text, id, children} = @props)->
    tooltip = <Tooltip id={id}>{text}</Tooltip>

    <OverlayTrigger overlay={tooltip} placement='top' delayShow={0} delayHide={0}>
      {children}
    </OverlayTrigger>
