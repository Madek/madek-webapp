import xhr from 'xhr'
import React from 'react'
import Moment from 'moment'
import currentLocale from '../../../lib/current-locale.js'
import t from '.../../../lib/i18n-translate.js'
import getRailsCSRFToken from '../../../lib/rails-csrf-token.js'
import interpolateSplit from '../../../lib/interpolate-split.js'
import cx from 'classnames'
import UI from '../../ui-components/index.js'

class MyNotifications extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      notifications: props.get.notifications,
      expandedDates: {},
      expandedCaseSections: {}
    }

    this.settingsByCase = {
      transfer_responsibility: {
        title: t('notifications_title_transfer_responsibility'),
        renderContent: this._renderTransferResponsibilityContent,
        sectionizeByDelegation: true
      },
      // sample notification case for frontend development
      weather_report: {
        title: 'Weather report',
        renderContent: this._renderWeatherReportContent,
        sectionizeByDelegation: false
      }
    }
  }

  render({ notifications } = this.state) {
    const { get } = this.props
    const { notification_case_labels: caseLabels, delegations } = get
    return (
      <div className="ui-resources-holder pal notifications">
        {caseLabels.map(caseLabel => {
          // fallback in case of unknown case
          const fallbackCase = {
            title: caseLabel,
            renderContent: data => JSON.stringify(data),
            sectionizeByDelegation: false
          }
          const caseSettings = this.settingsByCase[caseLabel] || fallbackCase

          const sections = caseSettings.sectionizeByDelegation ? [null, ...delegations] : [null]
          return sections.map(d => {
            const sectionNotifications = notifications.filter(
              n =>
                n.notification_case_label === caseLabel &&
                n.via_delegation_id === (d === null ? null : d.id)
            )
            return this.renderCaseSection(caseLabel, d, caseSettings, sectionNotifications)
          })
        })}
      </div>
    )
  }

  renderCaseSection(caseLabel, delegation, caseSettings, allNotificationsInSection) {
    const delegationId = delegation ? delegation.id : null
    const sectionKey = `${caseLabel}.${delegationId}`
    const { title, renderContent } = caseSettings
    const detailRenderFunc = data => renderContent(data, delegation)

    const hasExpandButton = allNotificationsInSection.length > 200
    const isExpanded = !hasExpandButton || this._isCaseSectionExpanded(sectionKey)
    const caseNotifications = isExpanded
      ? allNotificationsInSection
      : allNotificationsInSection.slice(0, 200)

    const notificationsByDate = caseNotifications.reduce((acc, n) => {
      const date = Moment(n.created_at).format('L')
      acc[date] = acc[date] || []
      acc[date].push(n)
      return acc
    }, {})

    return (
      <div key={sectionKey}>
        <h2 className="title-l mbs">
          {title} {delegation && 'Verantwortungs-Gruppe ' + delegation.name}
          <span className="notifications-count"> ({allNotificationsInSection.length})</span>
          {hasExpandButton && (
            <span>
              <a className="mls" onClick={() => this._handleCaseSectionExpandClick(sectionKey)}>
                {isExpanded
                  ? t('notifications_section_collapse')
                  : t('notifications_section_expand')}
              </a>
            </span>
          )}
        </h2>
        {allNotificationsInSection.length > 0 && isExpanded && (
          <div className="mbs">
            <button
              type="button"
              className="button"
              onClick={e => this._acknowledgeAll(e, caseLabel, delegationId)}>
              <i className="icon-close"></i> {t('notifications_acknowledge_all')}
            </button>
          </div>
        )}
        <div className="mbl">
          {allNotificationsInSection.length === 0 && (
            <div className="mll">{t('notifications_no_notifications')}</div>
          )}
          {Object.entries(notificationsByDate).map(([date, notifications]) => {
            return this._renderDateNotifications(sectionKey, date, notifications, detailRenderFunc)
          })}
        </div>
      </div>
    )
  }

  _renderDateNotifications(sectionKey, date, notifications, detailRenderFunc) {
    const tooMany = notifications.length > 3
    const isDateExpanded = this._isDateExpanded(sectionKey, date, !tooMany)
    const withTitle = notifications.length > 1
    return (
      <div key={date} className="mbs">
        {withTitle && (
          <h3
            className={cx('notification-date-title', {
              'notification-date-title--expanded': isDateExpanded
            })}>
            <span
              role="button"
              className={cx('notification-date-title__expand-button', {
                'notification-date-title__expand-button--expanded': isDateExpanded
              })}
              onClick={() => this._handleDateExpandClick(sectionKey, date, !tooMany)}></span>
            <UI.Tooltipped
              text={interpolateSplit(t('notifications_acknowledge_date_tooltip'), { date }).join(
                ''
              )}
              id={`btn.${sectionKey}.${date}`}>
              <button
                type="button"
                className={cx('button small icon-close notifications-mini-delete-button')}
                onClick={() => this._acknowledgeMultiple(notifications.map(x => x.id))}
                aria-label={t('notifications_acknowledge')}></button>
            </UI.Tooltipped>
            <a onClick={() => this._handleDateExpandClick(sectionKey, date, !tooMany)}>{date}</a>
            <span className="notifications-count">({notifications.length})</span>
          </h3>
        )}
        {isDateExpanded &&
          notifications.map(notification =>
            this._renderNotificationDetail(
              notification,
              !withTitle ? date : undefined,
              detailRenderFunc
            )
          )}
      </div>
    )
  }

  _renderNotificationDetail(notification, inlineDate, detailRenderFunc) {
    Moment.locale(currentLocale())

    const { id, data, acknowledged, created_at } = notification
    const timeLabel = Moment(created_at).format('LT')

    return (
      <div
        key={id}
        className={cx('notification-row', { 'notification-row--with-inline-date': inlineDate })}>
        {!acknowledged && (
          <UI.Tooltipped text={t('notifications_acknowledge')} id={`btn.${id}`}>
            <button
              type="button"
              className="button small icon-close notifications-mini-delete-button"
              onClick={() => this._acknowledge(id)}
              aria-label={t('notifications_acknowledge')}></button>
          </UI.Tooltipped>
        )}
        <div className="notification-row__datetime-cell">
          {inlineDate ? <b>{inlineDate}</b> : timeLabel}
        </div>
        <div>–</div>
        <div>{detailRenderFunc(data)}</div>
      </div>
    )
  }

  _renderTransferResponsibilityContent(data, viaDelegation) {
    const { user, resource } = data
    const text = viaDelegation
      ? t('notifications_message_transfer_responsibility_via_delegation')
      : t('notifications_message_transfer_responsibility')
    return interpolateSplit(text, {
      user: user.fullname,
      resourceType: resource.link_def.href.startsWith('/sets/')
        ? t('notifications_collection')
        : t('notifications_media_entry'),
      resource: (
        <a key="resource" href={resource.link_def.href}>
          {resource.link_def.label}
        </a>
      ),
      viaDelegation: viaDelegation ? viaDelegation.name : undefined
    })
  }

  _renderWeatherReportContent(data) {
    const { condition, degrees } = data
    return `Weather report says ${condition}, ${degrees}°C`
  }

  _updateNotifications(notifications) {
    this.setState({ notifications })
    document.querySelector('#side-navigation-notifications-counter').innerHTML =
      `(${notifications.length})`
  }

  _acknowledge(id) {
    sendAcknowledge(id, true, () =>
      this._updateNotifications(this.state.notifications.filter(n => n.id !== id))
    )
  }

  _acknowledgeAll(e, caseLabel, delegationId) {
    if (!confirm(t('notifications_really_acknowledge_all'))) {
      return
    }
    sendAcknowledgeAll(caseLabel, delegationId, () => {
      this._updateNotifications(
        this.state.notifications.filter(
          n => !(n.notification_case_label === caseLabel && n.via_delegation_id === delegationId)
        )
      )
    })
  }

  _acknowledgeMultiple(ids) {
    sendAcknowledgeMultiple(ids, () => {
      this._updateNotifications(this.state.notifications.filter(n => !ids.includes(n.id)))
    })
  }

  _handleCaseSectionExpandClick(sectionKey) {
    const key = `${sectionKey}`
    const currentValue = this._isCaseSectionExpanded(sectionKey)
    this.setState({
      expandedCaseSections: { ...this.state.expandedCaseSections, [key]: !currentValue }
    })
  }

  _isCaseSectionExpanded(sectionKey) {
    const value = this.state.expandedCaseSections[`${sectionKey}`]
    return value === undefined ? false : value
  }

  _handleDateExpandClick(sectionKey, date, defaultValue) {
    const key = `${sectionKey}/${date}`
    const currentValue = this._isDateExpanded(sectionKey, date, defaultValue)
    this.setState({
      expandedDates: { ...this.state.expandedDates, [key]: !currentValue }
    })
  }

  _isDateExpanded(sectionKey, date, defaultValue) {
    const value = this.state.expandedDates[`${sectionKey}/${date}`]
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

function sendAcknowledgeAll(caseLabel, delegationId, onSuccess) {
  xhr(
    {
      url: `/my/notifications/acknowledge_all`,
      method: 'POST',
      body: JSON.stringify({ notification_case_label: caseLabel, via_delegation_id: delegationId }),
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

function sendAcknowledgeMultiple(ids, onSuccess) {
  xhr(
    {
      url: `/my/notifications/acknowledge_multiple`,
      method: 'POST',
      body: JSON.stringify({ notification_ids: ids }),
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
