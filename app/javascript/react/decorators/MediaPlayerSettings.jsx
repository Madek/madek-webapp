import React, { useState } from 'react'
import PropTypes from 'prop-types'
import t from '../../lib/i18n-translate.js'
import currentLocale from '../../lib/current-locale.js'
import RailsForm from '../lib/forms/rails-form.jsx'

const SUBTITLE_LANGUAGES = [
  ['de', 'Deutsch'],
  ['en', 'English'],
  ['fr', 'Français'],
  ['it', 'Italiano'],
  ['es', 'Español'],
  ['pt', 'Português'],
  ['rm', 'Rumantsch'],
  ['nl', 'Nederlands'],
  ['pl', 'Polski'],
  ['ru', 'Русский'],
  ['tr', 'Türkçe'],
  ['ar', 'العربية'],
  ['zh', '中文'],
  ['ja', '日本語']
]

function languageLabel(code) {
  const match = SUBTITLE_LANGUAGES.find(([value]) => value === code)
  return match ? match[1] : ''
}

function languageOption(code, label) {
  const name = label || languageLabel(code)
  return name ? `${code} ${name}` : code
}

const subtitleShape = PropTypes.shape({
  id: PropTypes.string.isRequired,
  language: PropTypes.string,
  label: PropTypes.string,
  kind: PropTypes.string,
  filename: PropTypes.string,
  is_default: PropTypes.bool,
  url: PropTypes.string,
  delete_url: PropTypes.string
})

function formatConfig(config) {
  try {
    return JSON.stringify(config || {}, null, 2)
  } catch {
    return '{}'
  }
}

function FormActions({ cancelUrl, submitLabel }) {
  return (
    <div className="ui-actions pbl mtl">
      <a className="link weak" href={cancelUrl}>{` ${t('meta_data_form_cancel')} `}</a>
      <button className="primary-button large" type="submit">
        {submitLabel}
      </button>
    </div>
  )
}

FormActions.propTypes = {
  cancelUrl: PropTypes.string,
  submitLabel: PropTypes.string.isRequired
}

function ContentColumn({ children }) {
  return (
    <div className="app-body-content table-cell ui-container table-substance ui-container">
      <div className="form-body">{children}</div>
    </div>
  )
}

ContentColumn.propTypes = {
  children: PropTypes.node
}

export default function MediaPlayerSettings({ mediaPlayer, authToken, cancelUrl, thumbnail }) {
  const [configText, setConfigText] = useState(formatConfig(mediaPlayer.media_config))
  const [jsonError, setJsonError] = useState(false)
  const uiLanguage = currentLocale() === 'en' ? 'en' : 'de'
  const [language, setLanguage] = useState(uiLanguage)
  const [subtitleFileName, setSubtitleFileName] = useState('')
  const subtitles = mediaPlayer.subtitles || []

  const onConfigSubmit = event => {
    const value = configText.trim()
    try {
      const parsed = value === '' ? {} : JSON.parse(value)
      if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
        throw new Error('not an object')
      }
      setJsonError(false)
    } catch {
      event.preventDefault()
      setJsonError(true)
    }
  }

  return (
    <div className="ui-container phl ptl">
      {thumbnail}
      <ContentColumn>
        <RailsForm
          name="media_player_config"
          action={mediaPlayer.update_media_config_url}
          method="patch"
          authToken={authToken}
          onSubmit={onConfigSubmit}>
          <h3 className="title-l mbs">{t('media_player_media_config')}</h3>
          <fieldset className="ui-form-group rowed compact">
            <div className="form-item">
              <textarea
                id="media_file_media_config"
                name="media_file[media_config]"
                className="block code"
                rows={14}
                spellCheck="false"
                style={{ resize: 'block' }}
                value={configText}
                onChange={event => setConfigText(event.target.value)}
              />
              <p className="hint">
                {t('media_player_media_config_hint_pre')}
                <a href="https://videojs.org/" target="_blank" rel="noreferrer">
                  Video.js
                </a>
                {t('media_player_media_config_hint_post')}
              </p>
              {jsonError ? (
                <div className="ui-alerts">
                  <div className="error ui-alert">{t('media_player_config_invalid')}</div>
                </div>
              ) : null}
            </div>
          </fieldset>
          <FormActions cancelUrl={cancelUrl} submitLabel={t('media_player_save_config')} />
        </RailsForm>

        <hr className="separator light mvl" />

        <RailsForm
          name="subtitle_upload"
          action={mediaPlayer.create_subtitle_url}
          method="post"
          authToken={authToken}
          encType="multipart/form-data">
          <div className="row">
            <div className="col1of2">
              <h3 className="title-l mbs">{t('media_player_subtitles')}</h3>
              <div className="row">
                <div className="col1of3">
                  <div className="ui-form-group rowed compact">
                    <label className="form-label" htmlFor="subtitle_language">
                      {t('media_player_language')}
                    </label>
                    <div className="form-item prm">
                      <select
                        id="subtitle_language"
                        name="subtitle[language]"
                        className="block"
                        value={language}
                        onChange={event => setLanguage(event.target.value)}>
                        {SUBTITLE_LANGUAGES.map(([code, name]) => (
                          <option key={code} value={code}>{`${code} ${name}`}</option>
                        ))}
                      </select>
                      <input type="hidden" name="subtitle[label]" value={languageLabel(language)} />
                    </div>
                  </div>
                </div>
                <div className="col1of3">
                  <div className="ui-form-group rowed compact">
                    <label className="form-label" htmlFor="subtitle_kind">
                      {t('media_player_kind')}
                    </label>
                    <div className="form-item prm">
                      <select
                        id="subtitle_kind"
                        name="subtitle[kind]"
                        className="block"
                        defaultValue="subtitles">
                        <option value="subtitles">{t('media_player_kind_subtitles')}</option>
                        <option value="chapters">{t('media_player_kind_chapters')}</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div className="col1of3">
                  <div className="ui-form-group rowed compact">
                    <label className="form-label" htmlFor="subtitle_file">
                      {t('media_player_file')}
                    </label>
                    <div className="form-item">
                      <label className="button" htmlFor="subtitle_file" style={{ display: 'block', width: 'stretch' }}>
                        {t('media_player_choose_file')}
                      </label>
                      <input
                        id="subtitle_file"
                        name="subtitle[file]"
                        type="file"
                        accept=".vtt,text/vtt"
                        required
                        style={{
                          position: 'absolute',
                          width: '1px',
                          height: '1px',
                          padding: 0,
                          margin: '-1px',
                          overflow: 'hidden',
                          clip: 'rect(0, 0, 0, 0)',
                          whiteSpace: 'nowrap',
                          border: 0
                        }}
                        onChange={event => {
                          const file = event.target.files && event.target.files[0]
                          setSubtitleFileName(file ? file.name : '')
                        }}
                      />
                      <div className="mts">{subtitleFileName || t('media_player_no_file')}</div>
                    </div>
                  </div>
                </div>
              </div>
              <p className="hint">{t('media_player_kind_hint')}</p>
              <p className="hint">{t('media_player_default_hint')}</p>
            </div>
          </div>
          <FormActions cancelUrl={cancelUrl} submitLabel={t('media_player_upload')} />
        </RailsForm>

        <div className="row">
          <div className="col1of2">
            <div className="ui-form-group rowed compact">
              <div className="form-label">{t('media_player_uploaded_subtitles')}</div>
            </div>
            {subtitles.length === 0 ? <p>{t('media_player_no_subtitles')}</p> : null}
            {subtitles.map(subtitle => (
              <div className="row mbs" key={subtitle.id}>
                <div className="col3of4">
                  <a href={subtitle.url}>{subtitle.filename}</a>
                  {' · '}
                  {languageOption(subtitle.language, subtitle.label)}
                  {' · '}
                  {subtitle.kind === 'chapters'
                    ? t('media_player_kind_chapters')
                    : t('media_player_kind_subtitles')}
                </div>
                <div className="col1of4 by-right">
                  <RailsForm
                    name={`delete_subtitle_${subtitle.id}`}
                    action={subtitle.delete_url}
                    method="delete"
                    authToken={authToken}
                    onSubmit={event => {
                      if (!window.confirm(t('media_player_delete_confirm'))) event.preventDefault()
                    }}>
                    <button className="button" type="submit">
                      {t('media_player_delete')}
                    </button>
                  </RailsForm>
                </div>
              </div>
            ))}
          </div>
        </div>
      </ContentColumn>
    </div>
  )
}

MediaPlayerSettings.propTypes = {
  authToken: PropTypes.string,
  cancelUrl: PropTypes.string,
  thumbnail: PropTypes.node,
  mediaPlayer: PropTypes.shape({
    media_config: PropTypes.object,
    subtitles: PropTypes.arrayOf(subtitleShape),
    update_media_config_url: PropTypes.string.isRequired,
    create_subtitle_url: PropTypes.string.isRequired
  }).isRequired
}
