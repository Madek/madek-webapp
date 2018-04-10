import React, { PropTypes } from 'react'
import merge from 'lodash/merge'
import endsWith from 'lodash/endsWith'

import VideoJS from './VideoJs'

const propTypes = {
  sources: PropTypes.arrayOf(
    PropTypes.shape({
      url: PropTypes.string,
      content_type: PropTypes.string,
      profile: PropTypes.string
    })
  )
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
      // 'playbackRateMenuButton',
      // 'chaptersButton',
      // 'descriptionsButton',
      // 'subtitlesButton',
      // 'captionsButton',
      // 'audioTrackButton',
      'space',
      'customControlSpacer',
      'fullscreenToggle'
    ]
  },
  plugins: { videoJsResolutionSwitcher: { default: 'low', dynamicLabel: true } }
}

const sourceLabel = ({ profile }) => (endsWith(profile, '_HD') ? 'HD' : 'SD')

class VideoPlayer extends React.Component {
  _onVideoJsMount() {
    // _onVideoJsMount(player) {
    // console.log({ player })
  }

  render({ sources, ...props } = this.props) {
    const videoSources = sources.map(source => ({
      src: source.url,
      type: source.content_type,
      label: sourceLabel(source),
      res: source.height,
      key: `${source.url}${source.content_type}`
    }))

    return (
      <VideoJS
        {...props}
        sources={videoSources}
        onMount={this._onVideoJsMount}
        options={merge(VIDEOJS_OPTIONS, props.options)}
      />
    )
  }
}

VideoPlayer.propTypes = propTypes
export default VideoPlayer
