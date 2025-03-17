/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import cx from 'classnames'
import t from '../../../lib/i18n-translate.js'

module.exports = createReactClass({
  displayName: 'Views.MediaEntryEmbeddedImage',
  propTypes: {
    get: PropTypes.shape({
      title: PropTypes.string,
      caption_conf: PropTypes.shape({
        title: PropTypes.string,
        subtitle: PropTypes.string
      }),
      media_file: PropTypes.shape({
        previews: PropTypes.shape({
          images: PropTypes.objectOf(
            PropTypes.shape({
              url: PropTypes.string,
              width: PropTypes.number
            })
          )
        }),
        original_file_url: PropTypes.string
      }).isRequired,
      embed_config: PropTypes.shape({
        width: PropTypes.any,
        height: PropTypes.any
      }),
      url: PropTypes.string
    }).isRequired
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    const { title, caption_conf, media_file, embed_config, url } = get
    const { previews } = media_file
    const { width, height } = embed_config

    const style = {
      height: height > 0 ? height + 'px' : undefined,
      width: width > 0 ? width + 'px' : undefined
    }

    const titleTxt = title || t('picture_alt_fallback')
    const altTxt = `${t('picture_alt_prefix')} ${titleTxt}`

    // get URL of the x_large preview image
    const imageHref = previews.images['x_large'].url

    return (
      <div
        className={cx('embed-box', !style.height ? 'embed-box--responsive-height' : undefined)}
        style={style}>
        <a className="embed-box__img-container" href={url} target="_blank" rel="noreferrer">
          <img className="embed-box__img" src={imageHref} title={titleTxt} alt={altTxt} />
        </a>
        <a
          className="embed-box__caption embed-box-caption"
          href={url}
          target="_blank"
          rel="noreferrer">
          <span className="embed-box-caption__icon">
            <i className="icon-link" />
          </span>
          <h3 className="embed-box-caption__title">{caption_conf.title}</h3>
          <h4 className="embed-box-caption__subtitle">{caption_conf.subtitle}</h4>
        </a>
      </div>
    )
  }
})
