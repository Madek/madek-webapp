export default function titleBarPlugin({
  logo,
  logoTitle,
  title,
  subtitle,
  link,
  hideOnPlay = true
}) {
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
