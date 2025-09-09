import React, { Component } from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import omit from 'lodash/omit'
import isFunction from 'lodash/isFunction'
import titleBarPlugin from '../../lib/videojs-title-bar-plugin/videojs-title-bar-plugin'

// NOTE: this apparently needs to be defined globally, otherwise server side rendering breaks (I guess).
let videojs = null

// NOTE: this is used from Video- and AudioPlayer. `props.mode=audio|video`
// mode needs to be known because of conditional registering of plugins etc
const defaultProps = {
  mode: 'video',
  controls: true,
  preload: 'none',
  onMount: () => ({}),
  onReady: () => ({})
}

const propTypes = {
  options: PropTypes.shape({
    fluid: PropTypes.bool,
    width: PropTypes.number,
    height: PropTypes.number,
    ratio: PropTypes.string,
    controlBar: PropTypes.shape({
      children: PropTypes.arrayOf(PropTypes.string)
    })
  }),
  captionConf: PropTypes.any,
  isInternal: PropTypes.bool,
  mode: PropTypes.oneOf(['audio', 'video']),
  onReady: PropTypes.func,
  onMount: PropTypes.func,
  sources: PropTypes.arrayOf(
    PropTypes.shape({
      key: PropTypes.string,
      src: PropTypes.string,
      type: PropTypes.string
    })
  ),
  type: PropTypes.oneOf(['audio', 'video']),
  /** e.g. "500px" */
  width: PropTypes.string,
  /** e.g. "200px" */
  height: PropTypes.string,
  /** URL of a poster image */
  poster: PropTypes.string,
  preload: PropTypes.string,
  controls: PropTypes.bool,
  className: PropTypes.string
}

class VideoJS extends Component {
  constructor() {
    super()
    this.state = {
      active: typeof window !== 'undefined' && !!(window && window.document)
    }
    this.toCallOnUnmount = []
  }

  componentDidMount() {
    const { options, captionConf, isInternal, mode, onReady } = this.props
    const { fluid = true, ratio: aspectRatio = '16:9', width, height, controlBar } = options
    const { title, logoTitle, subtitle, link } = captionConf

    // configure plugins
    const titleBarConf = isInternal
      ? {}
      : {
          titleBar: {
            hideOnPlay: mode === 'video',
            title,
            logoTitle,
            subtitle,
            link,
            logo: 'Z'
          }
        }
    const resolutionSwitcherConf =
      mode === 'video' ? { videoJsResolutionSwitcher: { default: 'low', dynamicLabel: true } } : {}

    const playerOptions = {
      fluid,
      aspectRatio,
      width,
      height,
      controlBar,
      plugins: { ...titleBarConf, ...resolutionSwitcherConf }
    }

    const videoTag = this.refs.videojs
    if (!videoTag) throw new Error('no videojs tag!')

    videojs = require('video.js')

    // make library available to our plugins and other extensions:
    window.videojs = videojs
    if (mode === 'video') {
      require('../../lib/videojs-resolution-switcher')
    }

    // init/start
    videojs.plugin('titleBar', titleBarPlugin)
    const player = videojs(videoTag, playerOptions)
    window.player = player
    this.toCallOnUnmount.push(player.destroy)

    // parent callbacks
    player.ready(() => onReady(player))
  }

  componentWillUnmount() {
    this.toCallOnUnmount && this.toCallOnUnmount.forEach(f => isFunction(f) && f())
  }
  render() {
    const { sources, mode, options, ...restProps } = this.props
    const { type, width, height, poster, preload, controls, className } = restProps
    if (!sources) throw new TypeError()

    const MediaTag = mode // "audio" or "video"
    const mediaProps = { type, width, height, poster, preload, controls }
    const classes = cx(className, 'videojs', 'video-js', 'video-fluid', 'vjs-default-skin')
    const playerContent = (
      <MediaTag
        ref="videojs"
        {...mediaProps}
        height={options.height}
        width={options.width}
        className={classes}>
        {sources.map(src => (
          <source key={src.key} {...omit(src, 'res')} data-resolution={src.res} />
        ))}
      </MediaTag>
    )

    // wrap the player in a div with a `data-vjs-player` attribute
    // so videojs won't create additional wrapper in the DOM
    // see https://github.com/videojs/video.js/pull/3856
    return <div data-vjs-player>{playerContent}</div>
  }
}

VideoJS.propTypes = propTypes
VideoJS.defaultProps = defaultProps
export default VideoJS
