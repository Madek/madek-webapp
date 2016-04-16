React = require('react')
f = require('active-lodash')
parseMods = require('../lib/parse-mods.coffee').fromProps
cx = require('classnames')
t = require('../../lib/string-translation.coffee')('de')

module.exports = React.createClass
  displayName: 'Picture'
  propTypes:
    src: React.PropTypes.string.isRequired
    title: React.PropTypes.string
    alt: React.PropTypes.string

  render: ({src, title, alt} = @props)->
    classes = cx(parseMods(@props))
    titleTxt = title or alt or t('picture_alt_fallback')
    altTxt = "#{t('picture_alt_prefix')} #{titleTxt}"

    <img className={classes} {...@props} title={titleTxt} alt={altTxt}/>
