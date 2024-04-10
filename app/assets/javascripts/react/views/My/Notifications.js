import xhr from 'xhr'
import React from 'react'
import Moment from 'moment'
import currentLocale from '../../../lib/current-locale'
import t from '.../../../lib/i18n-translate.js'
import getRailsCSRFToken from '../../../lib/rails-csrf-token.coffee'
import interpolateSplit from '../../../lib/interpolate-split.js'
import cx from 'classnames'
const UI = require('../../ui-components/index.coffee')

class MyNotifications extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      notifications: props.get.notifications,
      expandedSections: {}
    }

    this.caseMap = {
      transfer_responsibility: {
        title: t('notifications_title_transfer_responsibility'),
        renderContent: this._renderTransferResponsibilityContent
      },
      // sample notification case for frontend development
      weather_report: {
        title: 'Weather report',
        renderContent: this._renderWeatherReportContent
      }
    }
  }

  render({ notifications } = this.state) {
    const { get } = this.props
    const { notification_case_labels: caseLabels } = get
    return (
      <div className="ui-resources-holder pal">
        {caseLabels.map(caseLabel => {
          const { title, renderContent } = this.caseMap[caseLabel] || {
            title: caseLabel,
            renderContent: data => JSON.stringify(data)
          }

          const caseNotifications = notifications.filter(
            n => n.notification_case_label === caseLabel
          )

          const caseNotificationsByDate = caseNotifications.reduce((acc, n) => {
            const date = Moment(n.created_at).format('L')
            acc[date] = acc[date] || []
            acc[date].push(n)
            return acc
          }, {})

          return (
            <div key={caseLabel}>
              <h2 className="title-l mbs">{title}</h2>
              {caseNotifications.length > 0 && (
                <div className="mbs">
                  <button
                    type="button"
                    className="button"
                    onClick={() => this._acknowledgeAll(caseLabel)}>
                    <i className="icon-close"></i> {t('notifications_acknowledge_all')}
                  </button>
                </div>
              )}
              <div className="mbl">
                {caseNotifications.length === 0 && <div>{t('notifications_no_notifications')}</div>}
                {Object.entries(caseNotificationsByDate).map(([date, notifications]) => {
                  const tooMany = notifications.length > 3
                  const expanded = this._isExpanded(caseLabel, date, !tooMany)
                  return (
                    <div key={date} className="mbm">
                      <h3
                        className="notifications-date-title"
                        role="button"
                        onClick={() => this._handleExpanderClick(caseLabel, date, !tooMany)}>
                        <span
                          className={cx('notifications-date-title__icon', {
                            'notifications-date-title__icon--open': expanded
                          })}></span>
                        {date}
                      </h3>
                      {expanded &&
                        notifications.map(notification =>
                          this._renderNotificationDetail(notification, renderContent)
                        )}
                    </div>
                  )
                })}
              </div>
            </div>
          )
        })}
      </div>
    )
  }

  _renderNotificationDetail(notification, detailRenderFunc) {
    Moment.locale(currentLocale())

    const { id, data, acknowledged, created_at } = notification
    const timeLabel = Moment(created_at).format('LT')

    return (
      <div key={id} className="mbs mlm">
        {!acknowledged && (
          <UI.Tooltipped text={t('notifications_acknowledge')} id={`btn.${id}`}>
            <button
              type="button"
              className="button small icon-close mrx"
              onClick={() => this._acknowledge(id)}
              aria-label={t('notifications_acknowledge')}></button>
          </UI.Tooltipped>
        )}
        {timeLabel} - {detailRenderFunc(data)}
      </div>
    )
  }

  _renderTransferResponsibilityContent(data) {
    const { user, resource } = data
    return interpolateSplit(t('notifications_message_transfer_responsibility'), {
      user: user.fullname,
      resource: (
        <a key="resource" href={resource.link_def.href}>
          {resource.link_def.label}
        </a>
      )
    })
  }

  _renderWeatherReportContent(data) {
    const { condition, degrees } = data
    return `Weather report says ${condition}, ${degrees}°C`
  }

  _acknowledgeAll(caseLabel) {
    sendAcknowledgeAll(caseLabel, () => {
      this.setState({
        notifications: this.state.notifications.filter(n => n.notification_case_label !== caseLabel)
      })
    })
  }

  _acknowledge(id) {
    sendAcknowledge(id, true, () =>
      this.setState({
        notifications: this.state.notifications.filter(n => n.id !== id)
      })
    )
  }

  _handleExpanderClick(caseLabel, date, defaultValue) {
    const key = `${caseLabel}/${date}`
    const currentValue = this._isExpanded(caseLabel, date, defaultValue)
    this.setState({
      ...this.state,
      expandedSections: { ...this.state.expandedSections, [key]: !currentValue }
    })
  }

  _isExpanded(caseLabel, date, defaultValue) {
    const value = this.state.expandedSections[`${caseLabel}/${date}`]
    return value === undefined ? defaultValue : value
  }
}

module.exports = MyNotifications

function sendAcknowledge(id, acknowledged, onSuccess) {
  xhr(
    {
      url: `/my/notifications/${id}`,
      method: 'PATCH',
      body: JSON.stringify({ acknowledged }),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    (err, res) => {
      if (res.statusCode === 200) {
        onSuccess()
      } else {
        alert('Error')
      }
    }
  )
}

function sendAcknowledgeAll(caseLabel, onSuccess) {
  xhr(
    {
      url: `/my/notifications/acknowledge_all`,
      method: 'POST',
      body: JSON.stringify({ notification_case_label: caseLabel }),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    (err, res) => {
      if (res.statusCode === 200) {
        onSuccess()
      } else {
        alert('Error')
      }
    }
  )
}
