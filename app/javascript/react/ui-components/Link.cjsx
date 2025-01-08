React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.js')

module.exports = React.createClass
  displayName: 'Link'
  propTypes:
    href: React.PropTypes.string
    onClick: React.PropTypes.func
    children: React.PropTypes.node
    disabled: React.PropTypes.bool

  render: ({href, onClick, children} = @props)->
    restProps = f.omit(@props, ['mods'])
    isLink = if href or onClick then true
    className = ui.cx('link': isLink, ui.parseMods(@props), 'ui-link')

    # force disabled if no interaction:
    isDisabled = if !isLink then true else @props.disabled

    <a {...restProps} className={className} disabled={isDisabled}>
      {children}
    </a>
