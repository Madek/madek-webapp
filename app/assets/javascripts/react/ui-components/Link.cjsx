React = require('react')

module.exports = React.createClass
  displayName: 'Link'
  propTypes:
    href: React.PropTypes.string

  render: ({href, children} = @props)->
    Elm = if href
      'a'
    else
      'span'

    <Elm {...@props} href={href}>
      {children}
    </Elm>
