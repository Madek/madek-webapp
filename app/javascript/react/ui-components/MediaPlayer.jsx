import React, { useState, useEffect } from 'react'
import PropTypes from 'prop-types'
import { omit } from '../../lib/utils.js'
import t from '../../lib/i18n-translate.js'
import AudioPlayer from './AudioPlayer.jsx'
import VideoPlayer from './VideoPlayer.jsx'

const MediaPlayer = ({ type, poster, sources, getUrl, ...props }) => {
  const [active, setActive] = useState(false)
  const [showHint] = useState(false)

  useEffect(() => {
    setActive(true)
  }, [])

  const mediaProps = omit({ type, poster, sources, getUrl, ...props }, ['originalUrl'])

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
  } else {
    // use videojs for client-side videos
    // before the player is loaded, show the poster to minimize flicker
    // if js fails, user still get the HTML5 video tag
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
    } else {
      return <VideoPlayer {...mediaProps} />
    }
  }
}

MediaPlayer.propTypes = {
  type: PropTypes.oneOf(['audio', 'video']).isRequired,
  sources: PropTypes.arrayOf(
    PropTypes.shape({
      url: PropTypes.string.isRequired,
      content_type: PropTypes.string.isRequired
    }).isRequired
  ).isRequired,
  poster: PropTypes.string
}

export default MediaPlayer
module.exports = MediaPlayer
