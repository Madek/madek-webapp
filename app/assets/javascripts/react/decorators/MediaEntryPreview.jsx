const React = require('react')
// eslint-disable-next-line react/no-deprecated
const PropTypes = React.PropTypes
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')
const cx = require('classnames')
const qs = require('qs')
const parseUrl = require('url').parse

// const Link = require('../ui-components/Link.cjsx')
const Icon = require('../ui-components/Icon.cjsx')
const Picture = require('../ui-components/Picture.cjsx')
const ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
const MediaPlayer = require('../ui-components/MediaPlayer.cjsx')

// eslint-disable-next-line react/no-deprecated
module.exports = React.createClass({
  displayName: 'MediaEntryPreview',
  propTypes: {
    get: PropTypes.shape({
      title: PropTypes.string.isRequired,
      // image_url: PropTypes.string.isRequired,
      media_file: PropTypes.shape({
        previews: PropTypes.object
        // original_file_url: PropTypes.string
      }).isRequired
    }).isRequired,
    mods: PropTypes.any
  },

  render() {
    const { get, mediaProps, withLink, withZoomLink, isEmbedded } = this.props
    const { image_url, title, media_type, type, export_url } = get
    const { previews, original_file_url } = get.media_file

    const classes = cx(this.props.mods)

    const usesIframeEmbed = !isEmbedded && f.includes(['audio', 'video'], media_type)

    // get the largest image and use it as 'full size link'
    // NOTE: we want this link even if the file is the same,
    // for consistency and bc it's easier for users…
    const imageHref = f
      .chain(previews.images)
      .sortBy('width')
      .last()
      .get('url')
      .run()

    // just the picure element (might be wrapped)
    // prefer the given image_url, but fallback to largest
    const picture =
      image_url || imageHref ? (
        <Picture title={title} src={image_url || imageHref} {...mediaProps} />
      ) : (
        <ResourceIcon mediaType={media_type} thumbnail={false} type={type} />
      )

    const mediaPlayerConfig = f.merge(
      {
        poster: imageHref || image_url,
        originalUrl: original_file_url
      },
      mediaProps
    )

    const not_ready =
      (get.media_type == 'video' || get.media_type == 'audio') &&
      f.get(get, 'media_file.conversion_status') != 'finished'

    if (not_ready) {
      const warningText =
        get.media_file.conversion_status === 'submitted'
          ? [
              t('media_entry_conversion_progress_pre'),
              get.media_file.conversion_progress,
              t('media_entry_conversion_progress_post')
            ].join('')
          : t('media_entry_conversion_status_' + get.media_file.conversion_status)

      return (
        <div className={classes}>
          <div className="ui-alert warning">{warningText}</div>
          <div className="p pvh mth">
            {t('media_entry_conversion_hint')}
            <br />
            <span className="title-xs">{t('media_entry_conversion_reload')}</span>
          </div>
        </div>
      )
    }

    if (usesIframeEmbed) return <IframeEmbed
      url={get.url} accessToken={get.used_confidential_access_token}
    />

    const downloadRef = original_file_url ? original_file_url : export_url

    const content =
      // PDF
      this.props.get.media_type == 'document' ? (
        <div className="ui-has-magnifier">
          {downloadRef ? <a href={downloadRef}>{picture}</a> : picture}
          {downloadRef && (
            <a href={downloadRef} className="ui-magnifier">
              <Icon i="magnifier" mods="bright" />
            </a>
          )}
         </div>
      ) : // video player
      previews.videos ? (
        <MediaPlayer
          type="video"
          {...mediaPlayerConfig}
          sources={previews.videos}
          options={f.merge({ fluid: true }, f.get(mediaPlayerConfig, 'options'))}
          captionConf={this.props.captionConf}
          isInternal={this.props.isInternal}
        />
      ) : // audio player
      previews.audios ? (
        <MediaPlayer
          type="audio"
          {...mediaPlayerConfig}
          getUrl={get.url}
          sources={previews.audios}
          options={f.merge({ fluid: true }, f.get(mediaPlayerConfig, 'options'))}
          captionConf={this.props.captionConf}
          isInternal={this.props.isInternal}
        />
      ) : // picture with link and 'zoom' icon on hover
      imageHref && (withLink || withZoomLink) ? (
        <div className={cx({ 'ui-has-magnifier': withZoomLink })}>
          <a href={imageHref}>{picture}</a>
          {!!withZoomLink && (
            <a
              href={imageHref}
              target="_blank"
              rel="noreferrer noopener"
              className="ui-magnifier"
              style={{ textDecoration: 'none' }}>
              <Icon i="magnifier" mods="bright" />
            </a>
          )}
        </div>
      ) : (
        picture
      )

    return <div className={classes}>{content}</div>
  }
})

const IframeEmbed = ({ url, accessToken }) => {
  const parsedUrl = parseUrl(url)
  const params = qs.parse(parsedUrl.query)
  const iframeSrc =
    parsedUrl.pathname.replace(/\/*$/, '') +
    '/embedded?' +
    qs.stringify({ ...params, internalEmbed: 'yes', accessToken })

  return (
    <div className="ui-media-overview-preview">
      <div
        style={{
          width: '100%',
          position: 'relative',
          paddingTop: '56.25%'
        }}>
        <iframe
          src={iframeSrc}
          style={{
            height: '100% !important',
            width: '100% !important',
            position: 'absolute',
            top: '0',
            left: '0'
          }}
          allowFullScreen="true"
          webkitallowfullscreen="true"
          mozallowfullscreen="true"
        />
      </div>
    </div>
  )
}
