import React from 'react'
import PropTypes from 'prop-types'
import t from '../../lib/i18n-translate.js'

const LABELS = {
  mp4: 'media_player_format_mp4',
  hls: 'media_player_format_hls'
}

const MediaFormatBar = ({ formats, format, onChange, downloadUrl }) => (
  <div className="madek-format-bar">
    {formats.map(item => (
      <button
        key={item}
        type="button"
        className="primary-button"
        aria-pressed={format === item}
        onClick={() => onChange(item)}>
        {t(LABELS[item])}
      </button>
    ))}
    <span className="madek-format-bar__spacer" />
    {downloadUrl ? (
      <a className="primary-button" href={downloadUrl}>
        {t('media_player_download')}
      </a>
    ) : null}
  </div>
)

MediaFormatBar.propTypes = {
  formats: PropTypes.arrayOf(PropTypes.oneOf(['mp4', 'hls'])).isRequired,
  format: PropTypes.oneOf(['mp4', 'hls']).isRequired,
  onChange: PropTypes.func.isRequired,
  downloadUrl: PropTypes.string
}

export default MediaFormatBar
