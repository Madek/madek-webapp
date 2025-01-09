/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const ui = require('../lib/ui.js')
const t = require('../../lib/i18n-translate.js')

module.exports = React.createClass({
  displayName: 'Picture',
  propTypes: {
    src: React.PropTypes.string.isRequired,
    title: React.PropTypes.string,
    alt: React.PropTypes.string
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { src, title, alt, className, mods } = param
    const restProps = f.omit(this.props, ['mods'])
    const classes = ui.cx(className, mods, 'ui_picture')
    const titleTxt = title || alt || t('picture_alt_fallback')
    const altTxt = `${t('picture_alt_prefix')} ${titleTxt}`

    return (
      <img
        {...Object.assign({}, restProps, { className: classes, title: titleTxt, alt: altTxt })}
      />
    )
  }
})
