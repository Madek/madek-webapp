import React from 'react'
import PropTypes from 'prop-types'
import { endsWith } from 'lodash-es'

import VideoJS from './VideoJs.jsx'

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

// Prefer MP4/H.264 when the browser can decode it (e.g. Safari). If not, put WebM
// first — Firefox on Linux often claims container support for video/mp4 but then
// fails with MEDIA_ERR_DECODE and never falls back to later <source>s.
const MP4_H264_TYPE = 'video/mp4; codecs="avc1.42E01E, mp4a.40.2"'
const WEBM_VP8_TYPE = 'video/webm; codecs="vp8, vorbis"'

const preferMp4Sources = () => {
  if (typeof document === 'undefined') return true
  const video = document.createElement('video')
  const mp4 = video.canPlayType(MP4_H264_TYPE)
  const webm = video.canPlayType(WEBM_VP8_TYPE)
  if (!mp4 && webm) return false
  return true
}

const bySdFirst = (a, b) => {
  if (a.label === 'SD') return -1
  if (b.label === 'SD') return 1
  return 0
}

class VideoPlayer extends React.Component {
  render({ sources, options, ...props } = this.props) {
    const videoSources = sources.map(source => ({
      src: source.url,
      type: source.content_type,
      label: sourceLabel(source),
      res: source.height,
      key: `${source.url}${source.content_type}`
    }))

    const mp4s = videoSources.filter(source => source.type === 'video/mp4').sort(bySdFirst)
    const webms = videoSources.filter(source => source.type === 'video/webm').sort(bySdFirst)
    const sortedSources = preferMp4Sources() ? mp4s.concat(webms) : webms.concat(mp4s)

    return (
      <VideoJS {...props} sources={sortedSources} options={{ ...VIDEOJS_OPTIONS, ...options }} />
    )
  }
}

VideoPlayer.propTypes = propTypes
export default VideoPlayer
