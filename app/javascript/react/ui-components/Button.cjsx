React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.js')

module.exports = React.createClass
  displayName: 'Button'
  propTypes:
    href: React.PropTypes.string
    type: React.PropTypes.string
    className: React.PropTypes.string
    style: React.PropTypes.object
    onClick: React.PropTypes.func
    mod: React.PropTypes.oneOf(['primary', 'tertiary'])
    disabled: React.PropTypes.bool
    children: React.PropTypes.node.isRequired

  render: ({href, onClick, type, mod, disabled, children, className} = @props)->
    restProps = f.omit(@props, ['mod', 'mods'])
    baseClass = if className then className else if mod then "#{mod}-button" else 'button'
    disabled = true if not (href or onClick or type) # force disabled if no target

    classes = ui.cx({disabled: disabled}, ui.parseMods(@props), baseClass)
    Elm = switch # NOTE: try avoiding 'button' because styling…
      when (href or onClick) then 'a'
      when type then 'button'
      else 'span'

    <Elm {...restProps} className={classes}>
      {children}
    </Elm>
