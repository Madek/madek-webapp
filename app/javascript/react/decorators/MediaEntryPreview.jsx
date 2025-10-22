import React from 'react'
import PropTypes from 'prop-types'
import { getPath } from '../../lib/utils.js'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames'
import qs from 'qs'
import { parse as parseUrl } from 'url'

import Icon from '../ui-components/Icon.jsx'
import Picture from '../ui-components/Picture.jsx'
import ResourceIcon from '../ui-components/ResourceIcon.jsx'
import MediaPlayer from '../ui-components/MediaPlayer.jsx'

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
        />
      </div>
    </div>
  )
}

const MediaEntryPreview = ({
  get,
  mediaProps,
  withLink,
  withZoomLink,
  isEmbedded,
  mods,
  captionConf,
  isInternal
}) => {
  const { image_url, title, media_type, type, export_url } = get
  const { previews, original_file_url } = get.media_file

  const classes = cx(mods)

  const usesIframeEmbed = !isEmbedded && ['audio', 'video'].includes(media_type)

  // get the largest image and use it as 'full size link'
  // NOTE: we want this link even if the file is the same,
  // for consistency and bc it's easier for users…
  const images = previews.images || []
  const sortedImages = images.slice().sort((a, b) => a.width - b.width)
  const imageHref = sortedImages.length > 0 ? sortedImages[sortedImages.length - 1].url : null

  // just the picure element (might be wrapped)
  // prefer the given image_url, but fallback to largest
  const picture =
    image_url || imageHref ? (
      <Picture title={title} src={image_url || imageHref} {...mediaProps} />
    ) : (
      <ResourceIcon mediaType={media_type} thumbnail={false} type={type} />
    )

  const mediaPlayerConfig = {
    poster: imageHref || image_url,
    originalUrl: original_file_url,
    ...mediaProps
  }

  const not_ready =
    (get.media_type == 'video' || get.media_type == 'audio') &&
    getPath(get, 'media_file.conversion_status') != 'finished'

  const missingAvPreviews =
    (get.media_type == 'video' && (previews.videos || []).length == 0) ||
    (get.media_type == 'audio' && (previews.audios || []).length == 0)

  if (not_ready || missingAvPreviews) {
    const deFactoFailed = !not_ready && missingAvPreviews
    const status = deFactoFailed ? 'failed' : get.media_file.conversion_status
    const warningText =
      status === 'submitted'
        ? [
            t('media_entry_conversion_progress_pre'),
            get.media_file.conversion_progress,
            t('media_entry_conversion_progress_post')
          ].join('')
        : t('media_entry_conversion_status_' + status)

    return (
      <div className={classes}>
        <div className="ui-alert warning">{warningText}</div>
        {status === 'failed' ? (
          <div className="p pvh mth"></div>
        ) : (
          <div className="p pvh mth">
            {t('media_entry_conversion_hint')}
            <br />
            <span className="title-xs">{t('media_entry_conversion_reload')}</span>
          </div>
        )}
      </div>
    )
  }

  if (usesIframeEmbed)
    return <IframeEmbed url={get.url} accessToken={get.used_confidential_access_token} />

  const downloadRef = original_file_url ? original_file_url : export_url

  const content =
    // PDF
    get.media_type == 'document' ? (
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
        options={{ fluid: true, ...(getPath(mediaPlayerConfig, 'options') || {}) }}
        captionConf={captionConf}
        isInternal={isInternal}
      />
    ) : // audio player
    previews.audios ? (
      <MediaPlayer
        type="audio"
        {...mediaPlayerConfig}
        getUrl={get.url}
        sources={previews.audios}
        options={{ fluid: true, ...(getPath(mediaPlayerConfig, 'options') || {}) }}
        captionConf={captionConf}
        isInternal={isInternal}
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

MediaEntryPreview.propTypes = {
  get: PropTypes.shape({
    title: PropTypes.string.isRequired,
    // image_url: PropTypes.string.isRequired,
    media_file: PropTypes.shape({
      previews: PropTypes.object
      // original_file_url: PropTypes.string
    }).isRequired
  }).isRequired,
  mods: PropTypes.any
}

export default MediaEntryPreview
module.exports = MediaEntryPreview
