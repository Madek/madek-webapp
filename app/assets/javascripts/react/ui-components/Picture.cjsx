React = require('react')
f = require('active-lodash')
parseMods = require('../lib/parse-mods.coffee').fromProps
t = require('../../lib/string-translation.coffee')('de')

module.exports = React.createClass
  displayName: 'Picture'
  propTypes:
    src: React.PropTypes.string.isRequired
    alt: React.PropTypes.string

  render: ({src, alt} = @props)->
    klasses = parseMods(@props)
    altTxt = f.presence(alt) or t('picture_alt_fallback')
    altAttr = "#{t('picture_alt_prefix')} #{altTxt}"

    <img src={src} className={klasses} alt={altAttr}/>
