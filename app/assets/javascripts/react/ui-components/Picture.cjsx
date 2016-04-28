React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')
t = require('../../lib/string-translation')('de')

module.exports = React.createClass
  displayName: 'Picture'
  propTypes:
    src: React.PropTypes.string.isRequired
    title: React.PropTypes.string
    alt: React.PropTypes.string

  render: ({src, title, alt} = @props)->
    classes = ui.cx(ui.parseMods(@props), 'ui_picture')
    titleTxt = title or alt or t('picture_alt_fallback')
    altTxt = "#{t('picture_alt_prefix')} #{titleTxt}"

    <img className={classes} {...@props} title={titleTxt} alt={altTxt}/>
