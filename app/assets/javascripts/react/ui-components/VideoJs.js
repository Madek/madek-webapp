import React, { Component } from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import omit from 'lodash/omit'
import merge from 'lodash/merge'
import isFunction from 'lodash/isFunction'
const noop = () => ({})
// FIXME: crashes server, required on mount!
let videojs = null

// NOTE: this is used from Video- and AudioPlayer. `props.mode=audio|video`
// mode needs to be known because of conditional registering of plugins etc
const defaultProps = {
  mode: 'video',
  controls: true,
  preload: 'auto',
  onMount: noop,
  onReady: noop
}

const propTypes = {
  mode: PropTypes.oneOf(['audio', 'video']),
  sources: PropTypes.array,
  children: PropTypes.node
}

const DEFAULT_OPTIONS = {
  fluid: true,
  aspectRatio: '16:9'
}

class VideoJS extends Component {
  constructor() {
    super()
    this.state = { active: !!(window && window.document) }
    this.toCallOnUnmount = []
  }

  componentDidMount() {
    const { props } = this
    // eslint-disable-next-line react/no-string-refs
    const videoTag = this.refs.videojs
    if (!videoTag) throw new Error('no videojs tag!')

    videojs = require('video.js')
    const playerOptions = merge({}, DEFAULT_OPTIONS, omit(props.options, 'ratio'), {
      aspectRatio: this.props.options.ratio
    })

    // console.log({ playerOptions })

    // make library available to our plugins and other extensions:
    window.videojs = videojs
    if (props.mode === 'video') {
      require('../../lib/videojs-resolution-switcher')
    }

    if (!this.props.isInternal) {
      merge(playerOptions, {
        plugins: {
          titleBar: {
            hideOnPlay: props.mode === 'video',
            title: props.captionConf.title,
            logoTitle: props.captionConf.logoTitle,
            subtitle: props.captionConf.subtitle,
            link: props.captionConf.link,
            logo: 'Z'
          }
        }
      })
    }

    // init/start
    videojs.plugin('titleBar', titleBarPlugin)
    const player = videojs(videoTag, playerOptions)
    window.player = player
    this.toCallOnUnmount.push(player.destroy)

    // parent callbacks
    player.ready(() => props.onReady(player))
  }

  componentWillUnmount() {
    this.toCallOnUnmount && this.toCallOnUnmount.forEach(f => isFunction(f) && f())
  }
  render() {
    const { sources, children, mode, options, ...restProps } = this.props
    if (!children && !sources) throw new TypeError()

    const MediaTag = mode
    const mediaProps = omit(
      restProps,
      'captionConf',
      'isInternal',
      'getUrl',
      'onMount',
      'onReady',
      'doInit'
    )

    const classes = cx(
      this.props.className,
      'videojs',
      'video-js',
      'video-fluid',
      'vjs-default-skin'
    )

    const playerContent = (
      <MediaTag // eslint-disable-next-line react/no-string-refs
        ref="videojs"
        {...mediaProps}
        height={options.height}
        width={options.width}
        className={classes}>
        {children ||
          sources.map(src => (
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

// plugins

function titleBarPlugin({ logo, logoTitle, title, subtitle, link, hideOnPlay = true }) {
  const Dom = document.createElement.bind(document)
  const player = this

  const logoEl = Dom('span')
  logoEl.title = logoTitle

  const overlay = {
    el: Dom('a'),
    logo: logoEl,
    caption: Dom('span'),
    title: Dom('span'),
    subtitle: Dom('span')
  }
  overlay.el.className = 'vjs-titlebar'
  overlay.caption.className = 'vjs-titlebar-caption'
  overlay.title.className = 'vjs-titlebar-title'
  overlay.subtitle.className = 'vjs-titlebar-subtitle'
  if (logo) {
    overlay.logo.className = 'vjs-titlebar-logo'
  }

  overlay.el.href = link
  overlay.el.target = '_blank'
  overlay.el.rel = 'noreferrer noopener'

  overlay.title.textContent = title
  overlay.subtitle.textContent = subtitle
  overlay.caption.appendChild(overlay.title)
  overlay.caption.appendChild(overlay.subtitle)

  overlay.el.appendChild(overlay.caption)
  overlay.el.appendChild(overlay.logo)

  player.el().appendChild(overlay.el)

  // hide/show on play/pause
  if (hideOnPlay) {
    player.on('play', () => {
      if (!/vjs-hidden/.test(overlay.el.className)) {
        overlay.el.className += ' vjs-hidden'
      }
    })
    player.on('pause', () => {
      if (/vjs-hidden/.test(overlay.el.className)) {
        overlay.el.className = overlay.el.className.replace(/\s?vjs-hidden/, '')
      }
    })
  }
}
