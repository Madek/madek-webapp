import React from 'react'
import ui from '../lib/ui.js'
import Moment from 'moment'
import first from 'lodash/first'
import get from 'lodash/get'
import last from 'lodash/last'
import isEmpty from 'lodash/isEmpty'
// import app from 'ampersand-app'
import currentLocale from '../../lib/current-locale.js'

import HeaderPrimaryButton from '../views/HeaderPrimaryButton.jsx'
import { ActionsBar, Button } from '../ui-components/index.js'
import {
  ResourceLink,
  UserCreatedItem,
  activityGroup,
  activityItemByType,
  resourceInfo
} from './UserActivityStreamDeco'

const t = ui.t

const ActivityStream = ({
  events,
  nextLink,
  isFetchingPast,
  startDate,
  isEndOfStream,
  isPaginated,
  user,
  importUrl
}) => {
  Moment.locale(currentLocale())
  const firstDate = Moment(get(events, [0, 0, 'date']) || startDate).calendar()

  const content = isEmpty(events)
    ? fallbackMessage({ isPaginated, firstDate, importUrl })
    : events.map(
        (group, i) =>
          !!group && group.length > 1
            ? <ActivityGroup group={group} key={i} />
            : <ActivityItem {...group[0]} key={i} />
      )

  return (
    <div className='ui-container ptm pbl prl plm'>
      <div className='ui-activity-stream'>
        {content}
        {isEndOfStream && !isEmpty(events)
          ? <UserCreatedItem user={user} />
          : !isEmpty(events) &&
            <PaginationNav href={nextLink} isLoading={isFetchingPast} />}
      </div>
    </div>
  )
}

export default ActivityStream

const ActivityGroup = ({ group }) => {
  Moment.locale(currentLocale())
  const [icon, summary] = activityGroup({ group })
  const firstDate = Moment(first(group).date).calendar()
  const lastDate = Moment(last(group).date).calendar()
  const date = firstDate === lastDate ? firstDate : `${firstDate} — ${lastDate}`

  return (
    <div className='event event-group'>
      <div className='label'>
        {icon}
      </div>
      <div className='content'>
        <span className='date title-xs-alt'>
          {date}
        </span>
        <div className='summary'>
          <h2>
            {summary}
          </h2>
        </div>
        <ul className='extra text'>
          {group.map((item, i) => {
            const info = resourceInfo({ item, activityType: group[0].type })

            return (
              <li className='event' key={i}>
                <div className='content'>
                  <div className='summary'>
                    <h3>
                      <ResourceLink {...item.object} />
                      {!!info &&
                        <span className='date title-xs-alt'>
                          {' '}{info}
                        </span>}
                    </h3>
                  </div>
                </div>
              </li>
            )
          })}
        </ul>
      </div>
    </div>
  )
}

const ActivityItem = item => {
  Moment.locale(currentLocale())
  const [icon, summary] = activityItemByType(item)
  return (
    <div className='event event-item'>
      <div className='label'>
        {icon}
      </div>
      <div className='content'>
        <div className='date title-xs-alt'>
          {Moment(item.date).calendar()}
        </div>
        <div className='summary'>
          <h2 className='title-l'>
            {summary}
          </h2>
        </div>
        {}
        {!isEmpty(item.moreDates) &&
          <div className='meta'>
            <span className='date title-xs-alt'>
              {resourceInfo({ item, activityType: item.type })}
            </span>
          </div>}
      </div>
    </div>
  )
}

const fallbackMessage = ({ isPaginated, importUrl }) => {
  const message = isPaginated
    ? 'Nichts gefunden f\xFCr diesen Zeitraum.'
    : 'Sie haben noch keine Aktivit\xE4ten durchgef\xFChrt.'

  const action = isPaginated
    ? null
    : <HeaderPrimaryButton
        icon={'upload'}
        text={t('dashboard_create_media_entry_btn')}
        href={importUrl}
      />

  return (
    <div className='pvh mth mbl'>
      <div className='by-center'>
        <p className='title-l mbm'>
          {message}
        </p>
        {action}
      </div>
    </div>
  )
}

const PaginationNav = ({ isLoading, ...props }) => {
  const showActive = isLoading

  const text = showActive
    ? t('pagination_nav_nextloading')
    : t('pagination_nav_prevpage')

  return (
    <div className='ui-container pal'>
      <div className='no-js'>
        <ActionsBar>
          <Button {...props}>
            {t('pagination_nav_prevpage')}
          </Button>
        </ActionsBar>
      </div>
      <div className='js-only'>
        <ActionsBar>
          <Button disabled={showActive} {...props}>
            {text}
          </Button>
        </ActionsBar>
      </div>
    </div>
  )
}
