/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import ui from '../lib/ui.js'
import t from '../../lib/i18n-translate.js'

module.exports = createReactClass({
  displayName: 'Picture',
  propTypes: {
    src: PropTypes.string.isRequired,
    title: PropTypes.string,
    alt: PropTypes.string
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { title, alt, className, mods } = param
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
