React = require('react')
f = require('active-lodash')
cx = require('classnames')
t = require('../../../lib/i18n-translate.js')

MediaEntryPreview = require('../../decorators/MediaEntryPreview.jsx')

module.exports = React.createClass
  displayName: 'Views.MediaEntryEmbeddedImage'
  propTypes:
    get: React.PropTypes.shape(
      title: React.PropTypes.string,
      caption_conf: React.PropTypes.shape(
        title: React.PropTypes.string,
        subtitle: React.PropTypes.string
      ),
      media_file: React.PropTypes.shape(
        previews: React.PropTypes.shape(
          images: React.PropTypes.objectOf(
            React.PropTypes.shape(
              url: React.PropTypes.string,
              width: React.PropTypes.number
            )
          )
        ),
        original_file_url: React.PropTypes.string
      ).isRequired,
      embed_config: React.PropTypes.shape(
        width: React.PropTypes.any,
        height: React.PropTypes.any
      ),
      url: React.PropTypes.string
    ).isRequired

  render: ({get} = @props)->
    {title, caption_conf, media_file, embed_config, url} = get
    {previews, original_file_url} = media_file
    {width, height} = embed_config

    style = {
      height: (if height > 0 then height + 'px')
      width: (if width > 0 then width + 'px'),
    }

    titleTxt = title or t('picture_alt_fallback')
    altTxt = "#{t('picture_alt_prefix')} #{titleTxt}"

    # get URL of the x_large preview image
    imageHref = previews.images["x_large"].url

    <div className={cx("embed-box", if !style.height then "embed-box--responsive-height")} style={style}>
      <a className="embed-box__img-container" href={url} target="_blank">
        <img className="embed-box__img" src={imageHref} title={titleTxt} alt={altTxt} />
      </a>
      <a className="embed-box__caption embed-box-caption" href={url} target="_blank">
        <span className="embed-box-caption__icon">
          <i className="icon-link"></i>
        </span>
        <h3 className="embed-box-caption__title">
          {caption_conf.title}
        </h3>
        <h4 className="embed-box-caption__subtitle">
          {caption_conf.subtitle}
        </h4>
      </a>
    </div>
