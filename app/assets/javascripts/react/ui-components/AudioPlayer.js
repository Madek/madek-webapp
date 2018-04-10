import React, { PropTypes } from 'react'
import merge from 'lodash/merge'

import VideoJS from './VideoJs'

const VIDEOJS_OPTIONS = {
  height: 500,
  controlBar: {
    children: [
      'playToggle',
      'currentTimeDisplay',
      'timeDivider',
      'durationDisplay',
      'progressControl',
      // 'liveDisplay',
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
  }
}

// const WAVESURFER_OPTIONS = {
//   debug: true,
//   msDisplayMax: 10,
//   normalize: true,
//   // non-interactive
//   interact: false,
//   // save render time:
//   // pixelRatio: 1,
//   // design:
//   height: 500,
//   barWidth: 1,
//   cursorWidth: 2,
//   waveColor: '#7a9d29',
//   progressColor: '#ccc',
//   cursorColor: '#93bd31',
//   hideScrollbar: true
// }

const propTypes = {
  sources: PropTypes.arrayOf(
    PropTypes.shape({
      url: PropTypes.string,
      content_type: PropTypes.string,
      profile: PropTypes.string
    })
  )
}

class AudioPlayer extends React.Component {
  constructor() {
    super()
  }
  // // WIP wavesurfer:
  // _doVideojsInit({ videoTag, videojs, playerOptions }) {
  //   window.videojs = videojs
  //   require('wavesurfer.js')
  //   require('videojs-wavesurfer')
  //   // const wavesurferPlugin = require('videojs-wavesurfer')
  //   // videojs.plugin('wavesurfer', wavesurferPlugin)
  //   const player = videojs(videoTag, playerOptions)
  //
  //   // init wavesurfer plugin. it needs the media file as well
  //   // need to ask videojs to tell us what the HTML element selected selected
  //   const selectedSource = player.currentSrc()
  //   player.wavesurfer(merge({}, WAVESURFER_OPTIONS, { src: selectedSource }))
  //   // debugger
  //   player.ready(() => {
  //     // console.log('player ready!', selectedSource)
  //     player.currentSrc = () => 'videojs-wavesurfer'
  //     player.src(null)
  //   })
  // }

  render({ sources, ...props } = this.props) {
    // const showHint = false
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
          options={merge(VIDEOJS_OPTIONS, props.options)}
          // doInit={=> this._doVideojsInit()}
        />
      </div>
    )
  }
}

AudioPlayer.propTypes = propTypes
export default AudioPlayer
