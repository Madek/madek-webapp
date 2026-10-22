import React, { useState, useEffect } from 'react'
import PropTypes from 'prop-types'
import { omit } from '../../lib/utils.js'
import t from '../../lib/i18n-translate.js'
import AudioPlayer from './AudioPlayer.jsx'
import VideoPlayer from './VideoPlayer.jsx'
import MediaFormatBar from './MediaFormatBar.jsx'

const HLS_TYPE = 'application/vnd.apple.mpegurl'

const isHlsSource = source => source.content_type === HLS_TYPE || source.profile === 'hls'

const isHd = source => typeof source.profile === 'string' && source.profile.endsWith('_HD')

const MediaPlayer = ({ type, poster, sources, getUrl, preferredFormat, isInternal, ...props }) => {
  const [active, setActive] = useState(false)
  const [showHint] = useState(false)
  const hasMp4 = sources.some(source => source.content_type === 'video/mp4')
  const hasHls = sources.some(isHlsSource)
  let initialFormat = 'mp4'
  if (hasHls && !hasMp4) initialFormat = 'hls'
  if (hasMp4 && hasHls && preferredFormat === 'hls') initialFormat = 'hls'
  const [format, setFormat] = useState(initialFormat)
  const [selectedLabel, setSelectedLabel] = useState('SD')

  useEffect(() => {
    setActive(true)
  }, [])

  const mediaProps = omit({ type, poster, sources, getUrl, isInternal, ...props }, ['originalUrl'])
  const showBar = type === 'video' && isInternal && hasMp4 && hasHls

  if (type === 'audio') {
    return (
      <div style={{ margin: '0px', padding: '0px' }}>
        <AudioPlayer {...mediaProps} />
        {showHint && (
          <p style={{ marginTop: '40px' }}>
            {t('media_entry_file_format_not_supported_1')}
            <a href={getUrl + '/export'}>{t('media_entry_file_format_not_supported_2')}</a>
            {t('media_entry_file_format_not_supported_3')}
          </p>
        )}
      </div>
    )
  }

  const player = <VideoPlayer {...mediaProps} format={format} onQualityLabel={setSelectedLabel} />

  if (!active) {
    return (
      <div>
        <div className="no-js">
          <VideoPlayer {...mediaProps} />
        </div>
        <div className="js-only">
          <img src={poster} style={{ height: '100%', width: '100%' }} />
        </div>
      </div>
    )
  }

  if (!showBar) return player

  return (
    <div className="madek-format-player">
      <MediaFormatBar
        formats={['mp4', 'hls']}
        format={format}
        onChange={setFormat}
        downloadUrl={downloadUrlFor(sources, format, selectedLabel)}
      />
      <div className="madek-format-player__stage">{player}</div>
    </div>
  )
}

function downloadUrlFor(sources, format, selectedLabel) {
  if (format === 'hls') {
    const hls = sources.find(isHlsSource)
    return hls && hls.download_url
  }
  const mp4s = sources.filter(source => source.content_type === 'video/mp4')
  const match =
    mp4s.find(source => (isHd(source) ? selectedLabel === 'HD' : selectedLabel !== 'HD')) || mp4s[0]
  return match && match.download_url
}

MediaPlayer.propTypes = {
  type: PropTypes.oneOf(['audio', 'video']).isRequired,
  sources: PropTypes.arrayOf(
    PropTypes.shape({
      url: PropTypes.string.isRequired,
      content_type: PropTypes.string.isRequired,
      profile: PropTypes.string,
      download_url: PropTypes.string
    }).isRequired
  ).isRequired,
  poster: PropTypes.string,
  preferredFormat: PropTypes.oneOf(['mp4', 'hls']),
  isInternal: PropTypes.bool
}

export default MediaPlayer
