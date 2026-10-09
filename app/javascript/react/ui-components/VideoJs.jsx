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
    fill: PropTypes.bool,
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
  const preferred = options.find(option => option.source.preferred)
  if (preferred) return preferred.label
  const sd = options.find(option => option.label === 'SD')
  return (sd || options[0]).label
}

function sourceForLabel(sources, label) {
  if (!sources || !label) return null
  const match = uniqueQualityOptions(sources).find(entry => entry.label === label)
  return match ? match.source : null
}

const CAST_CHROME_STYLE = `
  media-cast-button {
    display: none !important;
  }
`

const AUDIO_CHROME_STYLE = `
  .audio-controls-content,
  .media-button,
  .media-tooltip,
  .media-menu-popup,
  .media-menu-radio-item,
  .media-popup-surface,
  .audio-dialog-popup,
  .media-time-toggle,
  .media-slider,
  .media-slider-track,
  .media-slider-track::before,
  .media-slider-fill::before,
  .media-slider-buffer::before,
  .media-volume-popover {
    border-radius: 0 !important;
    corner-shape: square !important;
  }

  .audio-controls-content {
    width: 100%;
    margin-top: auto;
  }
`

// The volume popover is shown with the Popover API, which moves it to the
// top layer. Anchor positioning then places it at the top of the frame
// (left for video, right for audio) instead of beside the mute button.
const VOLUME_POPOVER_STYLE = `
  media-volume-popover {
    position: static !important;
    inset: auto !important;
    top: auto !important;
    right: auto !important;
    bottom: auto !important;
    left: auto !important;
    translate: none !important;
    margin: 0 !important;
    display: none !important;
    flex: none;
    align-self: center;
  }

  media-volume-popover[data-open] {
    display: block !important;
  }

  /* Audio: keep the slider right of the mute button (like video),
     not as a left-side flyout with extra padding/gradient. */
  media-volume-popover[data-side="left"] {
    order: 0 !important;
    background-image: none !important;
    padding-inline: calc(var(--media-spacing) * 3) !important;
  }
`

// Audio: the volume slider is always visible, not only on hover of the mute button.
const AUDIO_VOLUME_ALWAYS_STYLE = `
  media-volume-popover {
    display: block !important;
    opacity: 1 !important;
    visibility: visible !important;
    pointer-events: auto !important;
  }
`

function orderedAudioSources(sources) {
  const rank = type => (type === 'audio/mpeg' ? 0 : 1)
  return sources
    .filter(source => source && source.src)
    .slice()
    .sort((a, b) => rank(a.type) - rank(b.type))
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
    this.qualityMenuAttempts = 0
    this.audioLayoutAttempts = 0
    this.volumePopoverAttempts = 0
    this.playbackCleanups = []
    this.layersRef = createRef()
    this.lyricsRef = createRef()
    this.onPlay = this.onPlay.bind(this)
    this.onPause = this.onPause.bind(this)
    this.onQualityChange = this.onQualityChange.bind(this)
    this.onQualityMenuChange = this.onQualityMenuChange.bind(this)
    this.onAudioAreaClick = this.onAudioAreaClick.bind(this)
  }

  // Audio has no picture to click on: clicking anywhere in the player area
  // (but not on controls, links or menus) toggles play/pause.
  onAudioAreaClick(event) {
    const media = this.mediaRef.current
    if (!media) return
    // React's synthetic event has no composedPath(); without the native one, clicks on
    // shadow-DOM controls (play button) are retargeted to the skin host and would be
    // handled twice (button toggles, then this handler toggles back).
    const native = event.nativeEvent || event
    const path = typeof native.composedPath === 'function' ? native.composedPath() : [event.target]
    const interactive = path.some(node => {
      if (!node || node === event.currentTarget) return false
      if (!node.tagName) return false
      const tag = node.tagName.toLowerCase()
      if (tag === 'audio') return false
      if (tag.startsWith('media-') || ['button', 'a', 'input', 'select', 'label'].includes(tag)) {
        return true
      }
      const cls = typeof node.className === 'string' ? node.className : ''
      return /\baudio-controls-content\b|\bmedia-popup\b|\bmedia-button\b/.test(cls)
    })
    if (interactive) return

    if (media.paused || media.ended) {
      const playPromise = media.play()
      if (playPromise && typeof playPromise.catch === 'function') playPromise.catch(() => {})
    } else {
      media.pause()
    }
  }

  componentDidMount() {
    const { onMount, onReady } = this.props
    onMount()
    this.bindMediaEvents()
    const media = this.mediaRef.current
    if (media && onReady) onReady(media)
    this.scheduleQualityMenuSync()
    this.scheduleAudioLayout()
    this.scheduleVolumePopover()
    this.bindPlayback()
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
      this.scheduleAudioLayout()
      this.scheduleVolumePopover()
    }

    if (
      prevProps.sources !== this.props.sources ||
      prevState.selectedLabel !== this.state.selectedLabel ||
      prevProps.mode !== this.props.mode
    ) {
      this.scheduleQualityMenuSync()
    }
  }

  componentWillUnmount() {
    this.unbindMediaEvents()
    if (this.qualityMenuTimer) clearTimeout(this.qualityMenuTimer)
    if (this.audioLayoutTimer) clearTimeout(this.audioLayoutTimer)
    if (this.volumePopoverTimer) clearTimeout(this.volumePopoverTimer)
    this.clearPlayback()
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

  onQualityMenuChange(event) {
    const nextLabel = event.detail && event.detail.value
    this.onQualityChange({ target: { value: nextLabel } })
  }

  scheduleAudioLayout() {
    if (this.props.mode !== 'audio') return
    if (this.audioLayoutTimer) clearTimeout(this.audioLayoutTimer)
    this.audioLayoutAttempts = 0
    const attempt = () => {
      this.audioLayoutAttempts += 1
      if (this.applyAudioLayout()) return
      if (this.audioLayoutAttempts >= 20) return
      this.audioLayoutTimer = setTimeout(attempt, 50)
    }
    this.audioLayoutTimer = setTimeout(attempt, 0)
  }

  scheduleVolumePopover() {
    if (this.volumePopoverTimer) clearTimeout(this.volumePopoverTimer)
    this.volumePopoverAttempts = 0
    const attempt = () => {
      this.volumePopoverAttempts += 1
      if (this.pinVolumePopover()) return
      if (this.volumePopoverAttempts >= 20) return
      this.volumePopoverTimer = setTimeout(attempt, 50)
    }
    this.volumePopoverTimer = setTimeout(attempt, 0)
  }

  pinVolumePopover() {
    const media = this.mediaRef.current
    const skin = media && media.closest('video-neutral-skin, audio-neutral-skin')
    const shadow = skin && skin.shadowRoot
    const pop = shadow && shadow.querySelector('media-volume-popover')
    if (!pop) return false

    if (!shadow.querySelector('#madek-volume-popover')) {
      const style = document.createElement('style')
      style.id = 'madek-volume-popover'
      style.textContent =
        VOLUME_POPOVER_STYLE + (this.props.mode === 'audio' ? AUDIO_VOLUME_ALWAYS_STYLE : '')
      shadow.append(style)
    }

    if (!pop.dataset.madekVolumePinned) {
      pop.dataset.madekVolumePinned = 'true'
      try {
        HTMLElement.prototype.hidePopover.call(pop)
      } catch {
        // Not in the top layer yet.
      }
      pop.showPopover = () => {
        try {
          HTMLElement.prototype.hidePopover.call(pop)
        } catch {
          // Stays in the control bar.
        }
      }
    }
    return true
  }

  applyAudioLayout() {
    const media = this.mediaRef.current
    const skin = media && media.closest('audio-neutral-skin')
    const root = skin && skin.shadowRoot
    const frame = root && root.querySelector('.audio-skin')
    if (!frame) return false

    // The packaged audio skin forces height:auto !important inside a cascade
    // layer, which keeps the control bar at the top. Inline !important wins.
    frame.style.setProperty('height', '100%', 'important')
    frame.style.setProperty('min-height', '0', 'important')
    frame.style.setProperty('display', 'flex', 'important')
    frame.style.setProperty('flex-direction', 'column', 'important')
    frame.style.setProperty('justify-content', 'flex-end', 'important')
    frame.style.setProperty('border-radius', '0', 'important')

    if (!root.querySelector('#madek-audio-layout')) {
      const style = document.createElement('style')
      style.id = 'madek-audio-layout'
      style.textContent = AUDIO_CHROME_STYLE
      root.append(style)
    }
    this.mountAudioCaptions(root, media)
    return true
  }

  clearPlayback() {
    ;(this.playbackCleanups || []).forEach(remove => remove())
    this.playbackCleanups = []
  }

  listen(target, type, handler) {
    if (!target || !handler) return
    target.addEventListener(type, handler)
    this.playbackCleanups.push(() => target.removeEventListener(type, handler))
  }

  playbackTracks(kind) {
    const tracks = (this.props.playback && this.props.playback.tracks) || []
    if (!kind) return tracks
    return tracks.filter(track =>
      kind === 'subtitles' ? track.kind !== 'chapters' : track.kind === kind
    )
  }

  bindPlayback() {
    this.clearPlayback()
    const media = this.mediaRef.current
    if (!media || !this.props.playback) return
    const preferred = this.playbackTracks('subtitles').find(track => track.default)
    if (preferred) this.watchSubtitles(media, preferred.srclang)
    this.watchChapters(media)
    this.watchLayers(media)
    if (this.props.mode === 'audio') this.watchLyrics(media)
  }

  watchSubtitles(media, language) {
    const started = Date.now()
    const apply = () => {
      if (this.adjustingTracks) return
      if (Date.now() - started > 1500) {
        if (media.textTracks) media.textTracks.removeEventListener('change', apply)
        return
      }
      const subtitles = [...(media.textTracks || [])].filter(
        track => track.kind === 'subtitles' || track.kind === 'captions'
      )
      const preferred = subtitles.find(track => track.language === language)
      if (!preferred) return
      this.adjustingTracks = true
      subtitles.forEach(track => {
        const mode = track === preferred ? 'showing' : 'disabled'
        if (track.mode !== mode) track.mode = mode
      })
      this.adjustingTracks = false
    }
    this.listen(media.textTracks, 'change', apply)
    this.listen(media, 'loadedmetadata', apply)
    apply()
  }

  watchChapters(media) {
    const apply = () => {
      if (this.adjustingTracks) return
      const chapters = [...(media.textTracks || [])].filter(track => track.kind === 'chapters')
      if (!chapters.length) return
      const showing = [...(media.textTracks || [])].find(
        track => (track.kind === 'subtitles' || track.kind === 'captions') && track.mode === 'showing'
      )
      const active =
        chapters.find(track => track.language === (showing && showing.language)) || chapters[0]
      this.adjustingTracks = true
      chapters.forEach(track => {
        const mode = track === active ? 'hidden' : 'disabled'
        if (track.mode !== mode) track.mode = mode
      })
      this.adjustingTracks = false
    }
    this.listen(media, 'loadedmetadata', apply)
    this.listen(media.textTracks, 'change', apply)
    apply()
  }

  watchLayers(media) {
    const root = this.layersRef.current
    if (!root) return
    const headers = [...root.querySelectorAll('.madek-player-header')]
    const overlays = [...root.querySelectorAll('.madek-player-overlay')]
    const fallback =
      (this.playbackTracks('subtitles').find(track => track.default) || {}).srclang || ''
    const syncLanguage = () => {
      const showing = [...(media.textTracks || [])].find(
        track => (track.kind === 'subtitles' || track.kind === 'captions') && track.mode === 'showing'
      )
      const language = (showing && showing.language) || fallback
      overlays.forEach(overlay => {
        const variants = [...overlay.querySelectorAll('[data-lang]')]
        const match =
          variants.find(node => node.dataset.lang === language) ||
          variants.find(node => node.dataset.lang === fallback) ||
          variants[0]
        variants.forEach(node => {
          node.hidden = node !== match
        })
      })
    }
    const covers = element => {
      const time = media.currentTime || 0
      return time >= Number(element.dataset.start) && time < Number(element.dataset.end)
    }
    const stopsMedia = overlay =>
      overlay && overlay.dataset.stopMediaDuringOverlay === 'true'
    const overlayKey = overlay =>
      overlay ? `${overlay.dataset.start}-${overlay.dataset.end}` : ''
    let holdTimer = 0
    let pausedByOverlay = false
    let scriptedPlay = false
    let doneKey = ''
    const clearHold = () => {
      if (!holdTimer) return
      window.clearTimeout(holdTimer)
      holdTimer = 0
    }
    this.playbackCleanups.push(clearHold)
    const resumeFromOverlay = () => {
      if (!pausedByOverlay) return
      pausedByOverlay = false
      scriptedPlay = true
      const playPromise = media.play()
      if (playPromise && typeof playPromise.catch === 'function') playPromise.catch(() => {})
      scriptedPlay = false
    }
    const startHold = overlay => {
      if (!stopsMedia(overlay) || holdTimer || media.paused) return
      const key = overlayKey(overlay)
      if (doneKey === key) return
      media.pause()
      pausedByOverlay = true
      const remaining = Math.max(0, (Number(overlay.dataset.end) - media.currentTime) * 1000)
      holdTimer = window.setTimeout(() => {
        holdTimer = 0
        doneKey = key
        resumeFromOverlay()
        sync()
      }, remaining)
    }
    const sync = () => {
      const active = overlays.find(covers)
      const key = overlayKey(active)
      if (doneKey && doneKey !== key) {
        clearHold()
        doneKey = ''
        pausedByOverlay = false
      }
      if (!stopsMedia(active)) clearHold()
      headers.forEach(header => {
        header.hidden = !covers(header)
      })
      const showOverlay = Boolean(active) && !(stopsMedia(active) && doneKey === key)
      overlays.forEach(overlay => {
        overlay.hidden = overlay !== active || !showOverlay
      })
      if (showOverlay) startHold(active)
    }
    this.listen(media, 'play', () => {
      if (scriptedPlay || !holdTimer) return
      clearHold()
      doneKey = overlayKey(overlays.find(covers))
      pausedByOverlay = false
    })
    this.listen(media, 'timeupdate', sync)
    this.listen(media, 'seeked', sync)
    this.listen(media.textTracks, 'change', syncLanguage)
    syncLanguage()
    sync()
  }

  watchLyrics(media) {
    const lyrics = this.lyricsRef.current
    if (!lyrics) return
    const seen = new WeakSet()
    const sync = () => {
      const showing = [...(media.textTracks || [])].find(
        track => (track.kind === 'subtitles' || track.kind === 'captions') && track.mode === 'showing'
      )
      const cue = showing && showing.activeCues && showing.activeCues[0]
      lyrics.hidden = !cue
      lyrics.textContent = cue ? cue.text : ''
    }
    const watch = () => {
      ;[...(media.textTracks || [])].forEach(track => {
        if (seen.has(track)) return
        seen.add(track)
        this.listen(track, 'cuechange', sync)
      })
      sync()
    }
    this.listen(media.textTracks, 'addtrack', watch)
    this.listen(media.textTracks, 'change', sync)
    this.listen(media, 'timeupdate', sync)
    this.listen(media, 'seeked', sync)
    watch()
  }

  mountAudioCaptions(root, media) {
    const tracks = this.playbackTracks('subtitles')
    const end = root.querySelector('.audio-controls-end')
    if (!tracks.length || !end || end.querySelector('#madek-captions-trigger')) return

    const preferred = tracks.find(track => track.default)
    const button = document.createElement('button')
    button.type = 'button'
    button.id = 'madek-captions-trigger'
    button.className = 'media-button'
    button.setAttribute('commandfor', 'madek-captions-popup')
    button.setAttribute('aria-label', 'Subtitles')
    button.textContent = 'CC'

    const menu = document.createElement('media-menu')
    menu.id = 'madek-captions-popup'
    menu.setAttribute('side', 'top')
    menu.setAttribute('align', 'center')
    menu.className = 'media-popup media-popup-surface media-menu-popup'
    const content = document.createElement('media-menu-content')
    content.className = 'media-menu-content'
    const group = document.createElement('media-menu-radio-group')
    group.className = 'media-menu-radio-group'
    group.setAttribute('aria-label', 'Subtitles')
    group.value = preferred ? preferred.srclang : 'off'

    const addItem = (value, label) => {
      const item = document.createElement('media-menu-radio-item')
      item.className = 'media-menu-radio-item'
      item.value = value
      const text = document.createElement('span')
      text.setAttribute('data-part', 'label')
      text.textContent = label
      item.append(text)
      group.append(item)
    }
    addItem('off', 'Off')
    tracks.forEach(track => addItem(track.srclang, track.label || track.srclang))
    content.append(group)
    menu.append(content)
    // Order: mute / volume slider / CC / playback rate
    const volumePopover = end.querySelector('media-volume-popover')
    if (volumePopover) volumePopover.after(button, menu)
    else end.prepend(button, menu)

    group.addEventListener('value-change', event => {
      const language = event.detail && event.detail.value
      ;[...(media.textTracks || [])].forEach(track => {
        if (track.kind !== 'subtitles' && track.kind !== 'captions') return
        track.mode = language !== 'off' && track.language === language ? 'showing' : 'disabled'
      })
    })
  }

  scheduleQualityMenuSync() {
    if (this.qualityMenuTimer) clearTimeout(this.qualityMenuTimer)
    this.qualityMenuAttempts = 0
    const attempt = () => {
      this.qualityMenuAttempts += 1
      if (this.syncQualityMenu()) return
      if (this.qualityMenuAttempts >= 20) return
      this.qualityMenuTimer = setTimeout(attempt, 50)
    }
    this.qualityMenuTimer = setTimeout(attempt, 0)
  }

  hideCastButton(shadow) {
    if (!shadow.querySelector('#madek-hide-cast')) {
      const style = document.createElement('style')
      style.id = 'madek-hide-cast'
      style.textContent = CAST_CHROME_STYLE
      shadow.append(style)
    }
    shadow.querySelectorAll('media-cast-button').forEach(button => {
      const id = button.getAttribute('id')
      if (id) {
        shadow.querySelectorAll('media-tooltip').forEach(tip => {
          if (tip.getAttribute('trigger') === id) tip.remove()
        })
      }
      button.remove()
    })
  }

  syncQualityMenu() {
    if (this.props.mode !== 'video') return true
    const media = this.mediaRef.current
    const skin = media && media.closest('video-neutral-skin')
    const shadow = skin && skin.shadowRoot
    if (!shadow || !customElements.get('media-menu-radio-group')) return false
    this.hideCastButton(shadow)

    const options = uniqueQualityOptions(this.props.sources || [])
    const nativeGroup = shadow.querySelector('media-quality-radio-group')
    const page =
      (nativeGroup && nativeGroup.parentElement) ||
      shadow.querySelector('media-menu-radio-group.madek-quality-group')?.parentElement
    if (!page) return false

    if (options.length < 2) return true

    if (nativeGroup) nativeGroup.remove()

    let group = page.querySelector('media-menu-radio-group.madek-quality-group')
    if (!group) {
      group = document.createElement('media-menu-radio-group')
      group.className = 'media-menu-radio-group madek-quality-group'
      group.addEventListener('value-change', this.onQualityMenuChange)
      page.appendChild(group)
    }

    const labels = options.map(option => option.label)
    const currentLabels = [...group.querySelectorAll('media-menu-radio-item')].map(
      item => item.value
    )
    if (currentLabels.join('|') !== labels.join('|')) {
      group.replaceChildren(
        ...labels.map(label => {
          const item = document.createElement('media-menu-radio-item')
          item.className = 'media-menu-radio-item'
          item.value = label
          const text = document.createElement('span')
          text.setAttribute('data-part', 'label')
          text.textContent = label
          const indicator = document.createElement('media-menu-item-indicator')
          indicator.setAttribute('force-mount', '')
          indicator.className = 'media-menu-item-indicator'
          const icon = document.createElement('media-icon')
          icon.setAttribute('family', 'neutral')
          icon.setAttribute('name', 'check')
          icon.className = 'media-menu-radio-item-icon'
          indicator.appendChild(icon)
          item.append(text, indicator)
          return item
        })
      )
    }

    const selected = this.state.selectedLabel || labels[0]
    if (group.value !== selected) group.value = selected
    if (typeof group.publishMenuOptionState === 'function') {
      group.publishMenuOptionState(false, false, 'available')
    }
    const trigger = page.id && shadow.querySelector(`[commandfor="${page.id}"]`)
    return Boolean(trigger && trigger.getAttribute('data-availability') === 'available')
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

  renderTracks() {
    return this.playbackTracks().map(track => (
      <track
        key={`${track.kind}-${track.srclang}`}
        kind={track.kind === 'chapters' ? 'chapters' : 'subtitles'}
        src={track.src}
        srcLang={track.srclang}
        label={track.label}
        default={track.default ? true : undefined}
      />
    ))
  }

  renderPlaybackLayers() {
    const playback = this.props.playback
    if (!playback) return null
    const headers = playback.headers || []
    const overlays = playback.overlays || []
    const showLyrics =
      this.props.mode === 'audio' && this.playbackTracks('subtitles').length > 0
    if (!headers.length && !overlays.length && !showLyrics) return null
    const fallback =
      (this.playbackTracks('subtitles').find(track => track.default) || {}).srclang || ''

    return (
      <div className="madek-player-layers" ref={this.layersRef}>
        {headers.map(header => {
          const image = <img src={header.src} alt={header.alt || ''} />
          return header.href ? (
            <a
              key={`${header.src}-${header.start}`}
              className="madek-player-header"
              href={header.href}
              target={header.target || '_blank'}
              rel="noopener noreferrer"
              data-start={header.start}
              data-end={header.end}
              hidden={header.start > 0}>
              {image}
            </a>
          ) : (
            <span
              key={`${header.src}-${header.start}`}
              className="madek-player-header"
              data-start={header.start}
              data-end={header.end}
              hidden={header.start > 0}>
              {image}
            </span>
          )
        })}
        {overlays.map(overlay => (
          <div
            key={`${overlay.start}-${overlay.end}`}
            className="madek-player-overlay"
            data-start={overlay.start}
            data-end={overlay.end}
            data-stop-media-during-overlay={overlay.stop_media_during_overlay ? 'true' : 'false'}
            hidden>
            {Object.entries(overlay.text || {}).map(([code, text]) => (
              <span key={code} data-lang={code} hidden={code !== fallback}>
                {text}
              </span>
            ))}
          </div>
        ))}
        {showLyrics ? <div className="madek-player-lyrics" ref={this.lyricsRef} hidden /> : null}
      </div>
    )
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

    if (options.fill) {
      // Fill the iframe. A fixed pixel box overflows it and clips the player.
      skinStyle.width = '100%'
      skinStyle.height = '100%'
      skinStyle.minHeight = 0
      delete skinStyle.aspectRatio
      if (mode === 'audio') {
        // The audio skin is not display:contents, so percentage height collapses.
        // Pin it to the filled frame; applyAudioLayout anchors the bar at the bottom.
        skinStyle.position = 'absolute'
        skinStyle.inset = '0'
      } else {
        skinStyle.overflow = 'hidden'
        skinStyle.gridTemplateRows = 'minmax(0, 1fr)'
      }
    } else {
      if (options.width) skinStyle.width = options.width
      if (options.height) {
        delete skinStyle.aspectRatio
        skinStyle.height = options.height
      }
    }

    const mediaProps = {
      ref: this.mediaRef,
      preload: preload || 'none',
      playsInline: true,
      poster: mode === 'video' ? poster : undefined,
      src: selected ? selected.src : undefined,
      style:
        options.fill && mode === 'video'
          ? {
              position: 'absolute',
              inset: '0',
              width: '100%',
              height: '100%',
              maxWidth: '100%',
              maxHeight: '100%',
              objectFit: 'contain'
            }
          : undefined
    }

    const wrapperClass = cx(
      className,
      'madek-media-player',
      `madek-media-player--${mode}`,
      { 'madek-media-player--fill': options.fill }
    )

    if (mode === 'audio') {
      Object.assign(skinStyle, {
        '--media-controls-radius': '0',
        '--media-control-radius': '0',
        '--media-menu-item-radius': '0',
        '--media-popup-radius': '0',
        '--media-dialog-radius': '0',
        '--media-video-border-radius': '0',
        '--media-control-corner-shape': 'square'
      })
      const audioSources = orderedAudioSources(sources)
      const audioProps = { ...mediaProps }
      delete audioProps.src
      return (
        <div
          className={wrapperClass}
          style={{ cursor: 'pointer' }}
          onClick={this.onAudioAreaClick}>
          <audio-player>
            <audio-neutral-skin style={skinStyle}>
              <audio {...audioProps}>
                {audioSources.map(source => (
                  <source key={source.key || source.src} src={source.src} type={source.type} />
                ))}
                {this.renderTracks()}
              </audio>
            </audio-neutral-skin>
          </audio-player>
          {this.renderPlaybackLayers()}
        </div>
      )
    }

    return (
      <div className={wrapperClass}>
        <video-player poster={poster || undefined}>
          <video-neutral-skin style={skinStyle}>
            <video {...mediaProps}>{this.renderTracks()}</video>
          </video-neutral-skin>
        </video-player>
        {this.renderPlaybackLayers()}
        {this.renderTitleOverlay()}
      </div>
    )
  }
}

VideoJS.propTypes = propTypes
VideoJS.defaultProps = defaultProps
export default VideoJS
