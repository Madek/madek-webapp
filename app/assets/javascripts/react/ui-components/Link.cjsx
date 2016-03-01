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

    if @props.className
      className = @props.className + ' link'
    else
      className = 'link'
    <Elm {...@props} href={href} className={className}>
      {children}
    </Elm>
