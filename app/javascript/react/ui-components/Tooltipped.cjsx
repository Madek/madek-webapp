# Wrap this around anything for bootstrap-style tooltips

React = require('react')
Tooltip = require('react-bootstrap/lib/Tooltip')
Overlay = require('react-bootstrap/lib/Overlay')

module.exports = React.createClass
  displayName: 'Tooltipped'
  propTypes:
    text: React.PropTypes.string.isRequired
    link: React.PropTypes.element
    id: React.PropTypes.string.isRequired
    children: React.PropTypes.node.isRequired

  getInitialState: ->
    showTooltip: false

  showTooltip: ->
    clearTimeout(@_timer) if @_timer
    @setState(showTooltip: true)

  hideTooltip: ->
    @_timer = setTimeout(
      => @setState(showTooltip: false),
      30
    )

  getTriggerEl: (children) ->
    child = React.Children.toArray(children)[0]

    React.cloneElement(child,
      onMouseEnter: @showTooltip,
      onMouseLeave: @hideTooltip,
      ref: (el) => @_target = el
    )

  componentWillUnmount: ->
    clearTimeout(@_timer) if @_timer

  render: ({text, link, id, children} = @props) ->
    { showTooltip } = @state

    <span>
      {@getTriggerEl(children)}
      <Overlay
        show={showTooltip}
        target={@_target}
        placement='top'
      >
        <Tooltip
          id={id}
          onMouseEnter={@showTooltip}
          onMouseLeave={@hideTooltip}
        >
          {text}
          {<div>({link})</div> if link}
        </Tooltip>
      </Overlay>
    </span>
