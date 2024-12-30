import xhr from 'xhr'
import React from 'react'
import t from '.../../../lib/i18n-translate.js'
import interpolateSplit from '../../../lib/interpolate-split.js'
import getRailsCSRFToken from '../../../lib/rails-csrf-token.coffee'

class MySettings extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      emailsLocale: props.get.emails_locale,
      notificationCaseUserSettings: props.get.notification_case_user_settings.map(
        ({ label, email_frequency, allowed_email_frequencies }) => (
          { label, emailFrequency: email_frequency, allowedEmailFrequencies: allowed_email_frequencies }
        )
      ),
      dirty: false
    }
  }

  render() {
    const { get } = this.props
    const { notifications_url: notificationsUrl, email, available_locales: availableLocales } = get
    return (
      <div className="ui-resources-holder pal">
        <h2 className="title-l">{t('settings_notifications_title')}</h2>

        <p className="mbx">
          {interpolateSplit(t('settings_notifications_info1'), {
            notifications: (
              <a href={notificationsUrl} key="t1">
                {t('sitemap_notifications')}
              </a>
            )
          })}
        </p>

        <p className="mbx">{t('settings_notifications_info2')}</p>

        <p className="mbx">{t('settings_notifications_info3')}</p>

        <ul>
          <li className="mbx">
            {t('settings_notifications_email_label')} <b style={{ fontWeight: 'bold' }}>{email}</b>
          </li>
          <li className="mbx">
            {t('settings_notifications_locale_label')}{' '}
            <select
              name="emailsLocale"
              value={this.state.emailsLocale}
              onChange={e => this._handleEmailsLocaleChange(e.target.value)}>
              {' '}
              {availableLocales.map(l => (
                <option key={l} value={l}>
                  {t(`settings_notifications_locale_${l}`)}
                </option>
              ))}
            </select>
          </li>
        </ul>

        {this.state.notificationCaseUserSettings.map(caseSettings => {
          const { label, emailFrequency, allowedEmailFrequencies } = caseSettings
          return (
            <div key={label} className="mvs">
              <h3 className="title-m">{t(`settings_notifications_title_${label}`)}</h3>
              <p className="mbx">{t('settings_notifications_email_frequency_label')}</p>
              <div>
                {allowedEmailFrequencies.map(freq => (
                  <div key={freq}>
                    <label>
                      <input
                        type="radio"
                        name={label}
                        value={freq}
                        checked={freq === emailFrequency}
                        onChange={e => this._handleEmailFrequencyChange(label, e.target.value)}
                      />{' '}
                      {t(`settings_notifications_email_frequency_${freq}`)}
                    </label>
                  </div>
                ))}
              </div>
            </div>
          )
        })}

        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <button type="button" className="button" onClick={e => this._handleSaveClick(e)}>
            {t('settings_save_changes')}
          </button>
          {this.state.dirty && <span style={{ marginTop: '3px' }}>*</span>}
          {this.state.saved && (
            <span className="notifications-save-confirmation">{t('settings_saved_changes')}</span>
          )}
        </div>
      </div>
    )
  }

  componentWillUnmount() {
    window.removeEventListener('beforeunload', handleBeforeUnload)
  }

  _handleEmailsLocaleChange(emailsLocale) {
    this.setState({ ...this.state, emailsLocale, dirty: true })
  }

  _handleEmailFrequencyChange(label, freq) {
    this.setState({
      notificationCaseUserSettings: this.state.notificationCaseUserSettings.map(caseSettings => ({
        ...caseSettings,
        emailFrequency: caseSettings.label === label ? freq : caseSettings.emailFrequency
      })),
      dirty: true
    })
    window.addEventListener('beforeunload', handleBeforeUnload)
  }

  _handleSaveClick(e) {
    this.setState({ ...this.state, saved: false })

    const saveUrl = this.props.get.save_url
    sendUpdate(saveUrl, this.state, () => {
      this.setState({ ...this.state, dirty: false, saved: true })
      window.removeEventListener('beforeunload', handleBeforeUnload)
    })
    e.target.blur()
  }
}

module.exports = MySettings

function sendUpdate(url, settings, onSuccess) {
  const data = {
    emails_locale: settings.emailsLocale,
    notification_case_user_settings: settings.notificationCaseUserSettings.map(
      ({ label, emailFrequency }) => ({ label, email_frequency: emailFrequency })
    )
  }
  xhr(
    {
      url,
      method: 'PATCH',
      body: JSON.stringify(data),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    (err, res) => {
      if (res.statusCode === 200) {
        onSuccess()
      } else {
        alert('Error when saving')
      }
    }
  )
}

function handleBeforeUnload(event) {
  event.preventDefault()
  event.returnValue = ''
}
