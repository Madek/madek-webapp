import React from 'react'
import Moment from 'moment'
Moment.locale('de')
import ui from '../lib/ui.coffee'
const t = ui.t('de')
import first from 'lodash/first'
import last from 'lodash/last'
import isEmpty from 'lodash/isEmpty'
import isString from 'lodash/isString'
import trimString from 'lodash/trim'

import HeaderPrimaryButton from '../views/HeaderPrimaryButton.cjsx'
import Preloader from '../ui-components/Preloader.cjsx'

const fallbackMessage = <div className='pvh mth mbl'>
  <div className='by-center'>
    <p className='title-l mbm'>{'Sie haben noch keine Aktivitäten durchgeführt.'}</p>
    <HeaderPrimaryButton
      icon={'upload'} text={t('dashboard_create_media_entry_btn')}
      href={'/my/upload'} />

  </div>
</div>

const ActivityStream = ({events, isFetchingPast, isEndOfStream}) =>
  <div className='ui-container ptm pbl prl plm'>
    <div className='ui-activity-stream'>
      {isEmpty(events)
        ? fallbackMessage
        : events.map((group, i) =>
          !!group && (group.length > 1) && (group.length > 1)
            ? <ActivityGroup group={group} key={i}/>
            : <ActivityItem {...group[0]} key={i}/>
        )}
      <div className='ui-container pal'>
        {!!isFetchingPast && <Preloader mods='large pal' />}
      </div>
    </div>
  </div>

export default ActivityStream

const ActivityGroup = ({group}) => {
  const [icon, summary] = decorateActivityGroup({group})
  const firstDate = Moment(first(group).date).calendar()
  const lastDate = Moment(last(group).date).calendar()
  const date = (firstDate === lastDate)
    ? firstDate
    : `${firstDate} — ${lastDate}`

  return <div className='event event-group'>
    <div className='label'>{icon}</div>
    <div className='content'>
      <span className='date title-xs-alt'>
        {date}
      </span>
      <div className='summary'>
        <h2>{summary}</h2>
      </div>
      <ul className='extra text'>
          {group.map((item, i) => {
            const info = decorateResourceInfo({item, activityType: group[0].type})

            return <li className='event' key={i}>
              <div className='content'>
                <div className='summary'>
                  <h3>
                    <ResourceLink {...item.object} />
                    {!!info &&
                      <span className='date title-xs-alt'>{' '}{info}</span>
                    }
                  </h3>
                </div>
              </div>
            </li>
          })}
      </ul>
    </div>
  </div>
}

const ActivityItem = (item) => {
  const [icon, summary] = decorateActivityItemByType(item)
  return <div className='event event-item'>
    <div className='label'>
      {icon}
    </div>
    <div className='content'>
      <div className='date title-xs-alt'>{Moment(item.date).calendar()}</div>
      <div className='summary'>
        <h2 className='title-l'>{summary}</h2>
      </div>
      {/* if there are moreDates, only show a total count: */}
      {!isEmpty(item.moreDates) &&
        <div className='meta'>
          <span className='date title-xs-alt'>
            {decorateResourceInfo({item, activityType: item.type})}
          </span>
        </div>
      }
    </div>
  </div>
}

// UI - deco

const decorateActivityGroup = ({group}) => {
  // for an ActivityGroup, types, subjects, and object.types are always the same,
  // and only the first object is used for display, so get all props from it:
  const {type, subject, object} = group[0]

  const count = group.length
  const sub = subject ? subject.label : 'Jemand'

  switch (type) {
    case 'create':
      return [
        <i className='icon icon-plus' />,
        <span>
          {`Sie haben ${count} `}
          <ResourceLabelPlural {...object} />{' '}
          {'erstellt.'}
        </span>
      ]

    case 'edit':
      return [
        <i className='icon icon-pen' />,
        <span>
          {`Sie haben ${count} `}
          <ResourceLabelPlural {...object} />{' '}
          {'bearbeitet.'}
        </span>
      ]

    case 'share':
      return [
        <i className='icon icon-privacy-private-alt' />,
        <span>
          {sub}{' '}
          {`hat ${count} `}
          <ResourceLabelPlural {...object} />{' '}
          {'mit ihnen geteilt.'}
        </span>
      ]

    default:
      throw new TypeError('Unknown activity type! ' + type)
  }
}

const decorateActivityItemByType = ({type, subject, object}) => {
  const sub = subject ? subject.label : 'Jemand'
  switch (type) {
    case 'create':
      return [
        <i className='icon icon-plus' />,
        <span>
          {'Sie haben '}
          <ResourceLabel {...object}/>{' '}
          {' erstellt.'}
        </span>
      ]

    case 'edit':
      return [
        <i className='icon icon-pen' />,
        <span>
          {'Sie haben '}
          <ResourceLabel {...object} />{' '}
          {'bearbeitet.'}
        </span>
      ]

    case 'share':
      return [
        <i className='icon icon-privacy-private-alt' />,
        <span>
          {sub}{' '}
          {'hat '}
          <ResourceLabel {...object} />{' '}
          {'mit ihnen geteilt.'}
        </span>
      ]

    default:
      throw new TypeError('Unknown activity type! ' + type)
  }
}

const decorateResourceInfo = ({activityType, item}) => {
  switch (activityType) {

    case 'create':
      return false // there are no useful details for creation?

    case 'edit':
      //  if there are moreDates, show a total count:
      return isEmpty(item.moreDates) ? false
        : `(${item.moreDates.length + 1} Bearbeitungen)`

    case 'share':
      // TODO: decorate permission names
      return `(${item.details.join(', ')})`

    default:
      throw new TypeError('Unknown activity type! ' + activityType)
  }
}

const ResourceLabel = (resource) =>
  <span>
    {resource.type === 'MediaEntry' ? 'den Eintrag' : 'das Set'}{' '}
    <ResourceLink {...resource} />
  </span>

const ResourceLink = ({url, title = '(Unbekannt)'}) => {
  return <a href={url} title={title}>{truncateMiddle(title, {length: 100})}</a>
}

const ResourceLabelPlural = ({type}) =>
  <span>
    {type === 'MediaEntry' ? 'Einträge' : 'Sets'}
  </span>

// string helper, truncates long strings in the middle (better for visual comparisons)
function truncateMiddle (string, {length = 24, omission = '…', raw = false}) {
  if (!isString(string)) throw new TypeError('Not a String!')
  const symbols = Array.from(trimString(string)) // unicode-safe split!

  if (symbols.length <= length) return symbols.join('')

  const maxLength = length - omission.length
  let [start, end] = [Math.ceil(maxLength / 2), Math.floor(maxLength / 2)]

  const result = [
    symbols.slice(0, start).join(''),
    omission,
    symbols.slice(-end).join('')]

  return raw ? result : result.join('')
}
