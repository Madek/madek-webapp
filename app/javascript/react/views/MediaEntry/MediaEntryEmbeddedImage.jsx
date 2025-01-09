/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const cx = require('classnames')
const t = require('../../../lib/i18n-translate.js')

module.exports = React.createClass({
  displayName: 'Views.MediaEntryEmbeddedImage',
  propTypes: {
    get: React.PropTypes.shape({
      title: React.PropTypes.string,
      caption_conf: React.PropTypes.shape({
        title: React.PropTypes.string,
        subtitle: React.PropTypes.string
      }),
      media_file: React.PropTypes.shape({
        previews: React.PropTypes.shape({
          images: React.PropTypes.objectOf(
            React.PropTypes.shape({
              url: React.PropTypes.string,
              width: React.PropTypes.number
            })
          )
        }),
        original_file_url: React.PropTypes.string
      }).isRequired,
      embed_config: React.PropTypes.shape({
        width: React.PropTypes.any,
        height: React.PropTypes.any
      }),
      url: React.PropTypes.string
    }).isRequired
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    const { title, caption_conf, media_file, embed_config, url } = get
    const { previews, original_file_url } = media_file
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
        <a className="embed-box__img-container" href={url} target="_blank">
          <img className="embed-box__img" src={imageHref} title={titleTxt} alt={altTxt} />
        </a>
        <a className="embed-box__caption embed-box-caption" href={url} target="_blank">
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
