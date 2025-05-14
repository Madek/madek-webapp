import React from 'react'
import PropTypes from 'prop-types'
import endsWith from 'lodash/endsWith'

import VideoJS from './VideoJs'

const propTypes = {
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

const VIDEOJS_OPTIONS = {
  controlBar: {
    children: [
      'playToggle',
      'currentTimeDisplay',
      'timeDivider',
      'durationDisplay',
      'progressControl',
      'liveDisplay',
      'remainingTimeDisplay',
      'muteToggle',
      'volumeControl',
      'space',
      'customControlSpacer',
      'fullscreenToggle'
    ]
  }
}

const sourceLabel = ({ profile }) => (endsWith(profile, '_HD') ? 'HD' : 'SD')

class VideoPlayer extends React.Component {
  render({ sources, options, ...props } = this.props) {
    const videoSources = sources.map(source => ({
      src: source.url,
      type: source.content_type,
      label: sourceLabel(source),
      res: source.height,
      key: `${source.url}${source.content_type}`
    }))

    const mp4s = videoSources
      .filter(source => source.type === 'video/mp4')
      .sort((a, b) => {
        if (a.label === 'SD') {
          return -1
        } else if (b.label === 'SD') {
          return 1
        }
        return 0
      })

    const webms = videoSources
      .filter(source => source.type === 'video/webm')
      .sort((a, b) => {
        if (a.label === 'SD') {
          return -1
        } else if (b.label === 'SD') {
          return 1
        }
        return 0
      })

    const sortedSources = mp4s.concat(webms)

    return (
      <VideoJS {...props} sources={sortedSources} options={{ ...VIDEOJS_OPTIONS, ...options }} />
    )
  }
}

VideoPlayer.propTypes = propTypes
export default VideoPlayer
