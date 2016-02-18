React = require('react')
classList = require('classnames')
parseMods = require('../lib/parse-mods.coffee').fromProps

module.exports = React.createClass
  displayName: 'Button'
  propTypes:
    href: React.PropTypes.string
    type: React.PropTypes.string
    className: React.PropTypes.string
    style: React.PropTypes.string
    onClick: React.PropTypes.func
    mod: React.PropTypes.oneOf(['primary', 'tertiary'])
    disabled: React.PropTypes.bool
    children: React.PropTypes.node.isRequired

  render: ({href, onClick, type, mod, disabled, children, className} = @props)->
    baseClass = if className then className else if mod then "#{mod}-button" else 'button'
    disabled = true if not (href or onClick or type) # force disabled if no target

    classes = classList baseClass, parseMods(@props), disabled: disabled
    Elm = switch # NOTE: try avoiding 'button' because styling…
      when (href or onClick) then 'a'
      when type then 'button'
      else 'span'

    <Elm {...@props} className={classes}>
      {children}
    </Elm>
