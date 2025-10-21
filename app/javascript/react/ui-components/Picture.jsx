import React from 'react'
import PropTypes from 'prop-types'
import ui from '../lib/ui.js'
import t from '../../lib/i18n-translate.js'
import { omit } from '../../lib/utils.js'

const Picture = props => {
  const { title, alt, className, mods } = props
  const restProps = omit(props, ['mods'])
  const classes = ui.cx(className, mods, 'ui_picture')
  const titleTxt = title || alt || t('picture_alt_fallback')
  const altTxt = `${t('picture_alt_prefix')} ${titleTxt}`

  return <img {...restProps} className={classes} title={titleTxt} alt={altTxt} />
}

Picture.propTypes = {
  src: PropTypes.string.isRequired,
  title: PropTypes.string,
  alt: PropTypes.string
}

export default Picture
module.exports = Picture
