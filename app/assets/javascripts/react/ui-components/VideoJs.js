import React from 'react'
// import videojs from 'video.js' // FIXME: crashes server, required on mount!
import cx from 'classnames'
import omit from 'lodash/omit'
import merge from 'lodash/merge'

const DEFAULT_OPTIONS = {
  fluid: true,
  controlBar: {
    children: [
      'playToggle',
      'currentTimeDisplay',
      'timeDivider',
      'durationDisplay',
      'progressControl',
      'liveDisplay',
      'remainingTimeDisplay',
      'customControlSpacer',
      'muteToggle',
      'volumeControl',
      'playbackRateMenuButton',
      'chaptersButton',
      'descriptionsButton',
      'subtitlesButton',
      'captionsButton',
      'audioTrackButton',
      'fullscreenToggle'
    ]
  }
}

class VideoJS extends React.Component {
  componentDidMount () {
    const videoTag = this.refs.video
    if (!videoTag) throw new Error('no video tag!')

    const playerOptions = merge(DEFAULT_OPTIONS, this.props.options)
    // init:
    const videojs = require('video.js')
    this.player = videojs(videoTag, playerOptions)
  }

  render ({props, state} = this) {
    const {sources, ...restProps} = props
    const videoProps = omit(restProps, 'options')

    const classes = cx(this.props.className, 'videojs video-js video-fluid vjs-default-skin')

    return (
      <video ref='video' {...videoProps} className={classes}>
        {sources.map(({url, content_type}) =>
          <source src={url} type={content_type} key={`${url}${content_type}`}/>
        )}
      </video>
    )
  }
}

VideoJS.defaultProps = {
  controls: true,
  preload: 'auto'
}

export default VideoJS
