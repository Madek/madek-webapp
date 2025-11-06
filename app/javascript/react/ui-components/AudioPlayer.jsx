import React from 'react'
import PropTypes from 'prop-types'

import VideoJS from './VideoJs.jsx'

const VIDEOJS_OPTIONS = {
  height: 500,
  controlBar: {
    children: [
      'playToggle',
      'currentTimeDisplay',
      'timeDivider',
      'durationDisplay',
      'progressControl',
      'remainingTimeDisplay',
      'muteToggle',
      'volumeControl',
      'space',
      'customControlSpacer',
      'fullscreenToggle'
    ]
  }
}

const propTypes = {
  /** Soures of different type and quality (e.g. ogg, mp3) */
  sources: PropTypes.arrayOf(
    PropTypes.shape({
      url: PropTypes.string,
      content_type: PropTypes.string,
      profile: PropTypes.string
    })
  ),
  /** Options (geometry) */
  options: PropTypes.shape({
    fluid: PropTypes.bool,
    width: PropTypes.number,
    height: PropTypes.number,
    ratio: PropTypes.string
  })
}

class AudioPlayer extends React.Component {
  constructor() {
    super()
  }
  render({ sources, options, ...props } = this.props) {
    const videoSources = sources.map(source => ({
      src: source.url,
      type: source.content_type,
      key: `${source.url}${source.content_type}`
    }))
    return (
      <div style={{ margin: '0px', padding: '0px' }}>
        <VideoJS
          {...props}
          mode="audio"
          className="ui-audio-player"
          sources={videoSources}
          options={{ ...VIDEOJS_OPTIONS, ...options }}
        />
      </div>
    )
  }
}

AudioPlayer.propTypes = propTypes
export default AudioPlayer
