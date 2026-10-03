import React, { Component, createRef } from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'

// NOTE: this is used from Video- and AudioPlayer. `props.mode=audio|video`
const defaultProps = {
  mode: 'video',
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
      type: PropTypes.string,
      label: PropTypes.string,
      res: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
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
  className: PropTypes.string
}

function ratioToCss(ratio) {
  if (!ratio || typeof ratio !== 'string') return '16 / 9'
  const parts = ratio.split(':').map(part => part.trim())
  if (parts.length !== 2 || !parts[0] || !parts[1]) return '16 / 9'
  return `${parts[0]} / ${parts[1]}`
}

function uniqueQualityOptions(sources) {
  const byLabel = new Map()
  sources.forEach(source => {
    const label = source.label || 'SD'
    if (!byLabel.has(label)) byLabel.set(label, source)
  })
  return Array.from(byLabel.entries()).map(([label, source]) => ({ label, source }))
}

function pickInitialLabel(sources) {
  const options = uniqueQualityOptions(sources)
  if (options.length === 0) return null
  const sd = options.find(option => option.label === 'SD')
  return (sd || options[0]).label
}

function sourceForLabel(sources, label) {
  if (!sources || !label) return null
  const match = uniqueQualityOptions(sources).find(entry => entry.label === label)
  return match ? match.source : null
}

class TitleOverlay extends Component {
  render() {
    const { title, logoTitle, subtitle, link, hidden, logo } = this.props
    return (
      <a
        className={cx('madek-titlebar', { 'is-hidden': hidden })}
        href={link}
        target="_blank"
        rel="noreferrer noopener">
        <span className="madek-titlebar-caption">
          <span className="madek-titlebar-title">{title}</span>
          <span className="madek-titlebar-subtitle">{subtitle}</span>
        </span>
        {logo ? <span className="madek-titlebar-logo" title={logoTitle} /> : null}
      </a>
    )
  }
}

TitleOverlay.propTypes = {
  title: PropTypes.string,
  logoTitle: PropTypes.string,
  subtitle: PropTypes.string,
  link: PropTypes.string,
  hidden: PropTypes.bool,
  logo: PropTypes.bool
}

class VideoJS extends Component {
  constructor(props) {
    super(props)
    this.mediaRef = createRef()
    this.pendingRestore = null
    this.state = {
      selectedLabel: pickInitialLabel(props.sources || []),
      titleHidden: false
    }
    this.onPlay = this.onPlay.bind(this)
    this.onPause = this.onPause.bind(this)
    this.onQualityChange = this.onQualityChange.bind(this)
  }

  componentDidMount() {
    const { onMount, onReady } = this.props
    onMount()
    this.bindMediaEvents()
    const media = this.mediaRef.current
    if (media && onReady) onReady(media)
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevProps.sources !== this.props.sources) {
      const nextLabel = pickInitialLabel(this.props.sources || [])
      if (nextLabel !== this.state.selectedLabel) {
        this.setState({ selectedLabel: nextLabel })
      }
    }

    if (prevState.selectedLabel !== this.state.selectedLabel && this.pendingRestore) {
      this.restorePlaybackAfterSourceChange()
    }

    if (prevProps.mode !== this.props.mode) {
      this.bindMediaEvents()
    }
  }

  componentWillUnmount() {
    this.unbindMediaEvents()
  }

  bindMediaEvents() {
    this.unbindMediaEvents()
    const media = this.mediaRef.current
    if (!media) return
    media.addEventListener('play', this.onPlay)
    media.addEventListener('pause', this.onPause)
  }

  unbindMediaEvents() {
    const media = this.mediaRef.current
    if (!media) return
    media.removeEventListener('play', this.onPlay)
    media.removeEventListener('pause', this.onPause)
  }

  onPlay() {
    if (this.props.mode === 'video' && !this.props.isInternal) {
      this.setState({ titleHidden: true })
    }
  }

  onPause() {
    if (this.props.mode === 'video' && !this.props.isInternal) {
      this.setState({ titleHidden: false })
    }
  }

  onQualityChange(event) {
    const media = this.mediaRef.current
    const nextLabel = event.target.value
    if (!nextLabel || nextLabel === this.state.selectedLabel) return

    this.pendingRestore = media
      ? {
          currentTime: media.currentTime || 0,
          wasPlaying: !media.paused && !media.ended
        }
      : null

    this.setState({ selectedLabel: nextLabel })
  }

  restorePlaybackAfterSourceChange() {
    const media = this.mediaRef.current
    const restore = this.pendingRestore
    this.pendingRestore = null
    if (!media || !restore) return

    let resumed = false
    const finish = () => {
      if (resumed) return
      resumed = true
      media.removeEventListener('loadeddata', finish)
      media.removeEventListener('timeupdate', finish)
      try {
        media.currentTime = restore.currentTime
      } catch {
        // ignore seek errors while metadata is missing
      }
      if (restore.wasPlaying) {
        const playPromise = media.play()
        if (playPromise && typeof playPromise.catch === 'function') {
          playPromise.catch(() => {})
        }
      }
    }

    media.addEventListener('loadeddata', finish)
    media.addEventListener('timeupdate', finish)
    // preload=none may skip loadeddata until playback; match former plugin fallback
    setTimeout(finish, 100)
    media.load()
  }

  renderTitleOverlay() {
    const { captionConf, isInternal, mode } = this.props
    if (isInternal || !captionConf || mode !== 'video') return null
    const { title, logoTitle, subtitle, link } = captionConf
    return (
      <TitleOverlay
        title={title}
        logoTitle={logoTitle}
        subtitle={subtitle}
        link={link}
        logo
        hidden={this.state.titleHidden}
      />
    )
  }

  renderQualitySwitcher() {
    const { mode, sources } = this.props
    if (mode !== 'video' || !sources) return null
    const options = uniqueQualityOptions(sources)
    if (options.length < 2) return null
    return (
      <label className="madek-video-quality">
        <span className="madek-video-quality-label">Quality</span>
        <select
          className="madek-video-quality-select"
          value={this.state.selectedLabel || ''}
          onChange={this.onQualityChange}>
          {options.map(option => (
            <option key={option.label} value={option.label}>
              {option.label}
            </option>
          ))}
        </select>
      </label>
    )
  }

  render() {
    const { sources, mode, options = {}, poster, preload, className } = this.props
    if (!sources) throw new TypeError()

    const selected = sourceForLabel(sources, this.state.selectedLabel)
    const aspectRatio = ratioToCss(options.ratio)
    const skinStyle = {
      display: 'block',
      width: '100%',
      aspectRatio,
      '--media-accent-color': '#d0d0d0',
      '--media-accent-text-color': '#1a1a1a',
      '--media-font-family': "'Open Sans', sans-serif",
      '--media-scale-unit': '12px'
    }

    if (options.width) skinStyle.width = options.width
    if (options.height) {
      delete skinStyle.aspectRatio
      skinStyle.height = options.height
    }

    const mediaProps = {
      ref: this.mediaRef,
      preload: preload || 'none',
      playsInline: true,
      poster: mode === 'video' ? poster : undefined,
      src: selected ? selected.src : undefined
    }

    const wrapperClass = cx(className, 'madek-media-player', `madek-media-player--${mode}`)

    if (mode === 'audio') {
      return (
        <div className={wrapperClass}>
          <audio-player>
            <audio-neutral-skin style={skinStyle}>
              <audio {...mediaProps} />
            </audio-neutral-skin>
          </audio-player>
        </div>
      )
    }

    return (
      <div className={wrapperClass}>
        <video-player poster={poster || undefined}>
          <video-neutral-skin style={skinStyle}>
            <video {...mediaProps} />
          </video-neutral-skin>
        </video-player>
        {this.renderTitleOverlay()}
        {this.renderQualitySwitcher()}
      </div>
    )
  }
}

VideoJS.propTypes = propTypes
VideoJS.defaultProps = defaultProps
export default VideoJS
