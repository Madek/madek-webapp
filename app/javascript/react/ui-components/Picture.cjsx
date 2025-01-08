React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.js')
t = require('../../lib/i18n-translate.js')

module.exports = React.createClass
  displayName: 'Picture'
  propTypes:
    src: React.PropTypes.string.isRequired
    title: React.PropTypes.string
    alt: React.PropTypes.string

  render: ({src, title, alt, className, mods} = @props)->
    restProps = f.omit(@props, ['mods'])
    classes = ui.cx(className, mods, 'ui_picture')
    titleTxt = title or alt or t('picture_alt_fallback')
    altTxt = "#{t('picture_alt_prefix')} #{titleTxt}"

    <img {...restProps} className={classes} title={titleTxt} alt={altTxt}/>
