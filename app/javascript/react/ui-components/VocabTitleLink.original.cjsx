React = require('react')
Icon = require('./Icon.cjsx')
cs = require('classnames')

module.exports = React.createClass
  displayName: 'VocabTitleLink'

  render: ({id, hi, text, href, separated, className} = @props) ->
    H = if hi then hi else 'h3'
    defaultClasses = cs('title-l', {separated: separated, mbm: separated})
    classes = if className then className else defaultClasses
    <H className={classes} id={id}>
      {text}
      {' ' if href}
      {
        if href
          <a href={href} style={{textDecoration: 'none'}}>
            <Icon i='link' />
          </a>
      }
    </H>
