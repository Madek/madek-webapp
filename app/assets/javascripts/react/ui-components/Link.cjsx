React = require('react')
ui = require('../lib/ui.coffee')

module.exports = React.createClass
  displayName: 'Link'
  propTypes:
    href: React.PropTypes.string

  render: ({href, onClick, children} = @props)->
    isLink = if href or onClick then true
    NodeType = if isLink then 'a' else 'span'
    className = ui.cx('link': isLink, ui.parseMods(@props), 'ui-link')

    <NodeType className={className} {...@props}>
      {children}
    </NodeType>
