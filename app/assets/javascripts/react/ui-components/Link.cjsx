React = require('react')
cx = require('classnames')
parseMods = require('../lib/parse-mods.coffee').fromProps

module.exports = React.createClass
  displayName: 'Link'
  propTypes:
    href: React.PropTypes.string

  render: ({href, children} = @props)->
    Elm = if href then 'a' else 'span'
    className = cx('link', @props.className, parseMods(@props))

    <Elm {...@props} href={href} className={className}>
      {children}
    </Elm>
