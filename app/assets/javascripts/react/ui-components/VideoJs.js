import React from 'react'
// import videojs from 'video.js' // FIXME: crashes server, required on mount!
import cx from 'classnames'
import omit from 'lodash/omit'
import merge from 'lodash/merge'
import endsWith from 'lodash/endsWith'

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

const sourceLabel = ({ profile }) => endsWith(profile, '_HD') ? 'HD' : 'SD'

class VideoJS extends React.Component {
  componentDidMount () {
    const videoTag = this.refs.video
    if (!videoTag) throw new Error('no video tag!')

    const playerOptions = merge(DEFAULT_OPTIONS, this.props.options, {
      // NOTE: new source list because it must include config for HD-toggle
      sources: this.props.sources.map(source => ({
        src: source.url,
        type: source.content_type,
        label: sourceLabel(source),
        res: source.height
      })),
      plugins: {
        videoJsResolutionSwitcher: { default: 'low', dynamicLabel: true }
      }
    })

    // init:
    const videojs = require('video.js')
    window.videojs = videojs
    require('videojs-resolution-switcher')
    this.player = videojs(videoTag, playerOptions)
  }

  render ({ props, state } = this) {
    const { sources, ...restProps } = props
    const videoProps = omit(restProps, 'options')

    const classes = cx(
      this.props.className,
      'videojs video-js video-fluid vjs-default-skin'
    )

    return (
      <video ref='video' {...videoProps} className={classes}>
        {
          sources.map(source => (
            <source
              src={source.url}
              type={source.content_type}
              key={`${source.url}${source.content_type}`}
            />
          ))
        }
      </video>
    )
  }
}

VideoJS.defaultProps = { controls: true, preload: 'auto' }

export default VideoJS
