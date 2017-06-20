import React from 'react'
import Moment from 'moment'
import isEmpty from 'lodash/isEmpty'
import isString from 'lodash/isString'
import trimString from 'lodash/trim'
Moment.locale('de')

export const UserCreatedItem = ({ user }) =>
  user &&
  user.created_at &&
  <div className='event event-item'>
    <div className='label'>
      <i className='icon icon-user' />
    </div>
    <div className='content'>
      <div className='date title-xs-alt'>
        {Moment(user.created_at).calendar()}
      </div>
      <div className='summary'>
        <h2 className='title-l'>
          {`Sie haben sich angemeldet.`}
        </h2>
      </div>
    </div>
  </div>

export const activityGroup = ({ group }) => {
  // for an ActivityGroup, types, subjects, and object.types are always the same,
  // and only the first object is used for display, so get all props from it:
  const { type, subject, object } = group[0]

  const count = group.length
  const sub = subject ? subject.label : 'Jemand'

  switch (type) {
    case 'create':
      return [
        <i className='icon icon-plus' />,
        <span>
          {`Sie haben ${count} `}
          <ResourceLabelPlural {...object} /> {'erstellt.'}
        </span>
      ]

    case 'edit':
      return [
        <i className='icon icon-pen' />,
        <span>
          {`Sie haben ${count} `}
          <ResourceLabelPlural {...object} /> {'bearbeitet.'}
        </span>
      ]

    case 'share':
      return [
        <i className='icon icon-privacy-private-alt' />,
        <span>
          {sub} {`hat ${count} `}
          <ResourceLabelPlural {...object} /> {'mit ihnen geteilt.'}
        </span>
      ]

    default:
      throw new TypeError('Unknown activity type! ' + type)
  }
}

export const activityItemByType = ({ type, subject, object }) => {
  const sub = subject ? subject.label : 'Jemand'
  switch (type) {
    case 'create':
      return [
        <i className='icon icon-plus' />,
        <span>
          {'Sie haben '}
          <ResourceLabel {...object} /> {' erstellt.'}
        </span>
      ]

    case 'edit':
      return [
        <i className='icon icon-pen' />,
        <span>
          {'Sie haben '}
          <ResourceLabel {...object} /> {'bearbeitet.'}
        </span>
      ]

    case 'share':
      return [
        <i className='icon icon-privacy-private-alt' />,
        <span>
          {sub} {'hat '}
          <ResourceLabel {...object} /> {'mit ihnen geteilt.'}
        </span>
      ]

    default:
      throw new TypeError('Unknown activity type! ' + type)
  }
}

export const resourceInfo = ({ activityType, item }) => {
  switch (activityType) {
    case 'create':
      return false

    // there are no useful details for creation?
    case 'edit':
      //  if there are moreDates, show a total count:
      return isEmpty(item.moreDates)
        ? false
        : `(${item.moreDates.length + 1} Bearbeitungen)`

    case 'share':
      // TODO: decorate permission names
      return `(${item.details.join(', ')})`

    default:
      throw new TypeError('Unknown activity type! ' + activityType)
  }
}

export const ResourceLink = ({ url, title = '(Unbekannt)' }) => {
  return (
    <a href={url} title={title}>
      {truncateMiddle(title, { length: 100 })}
    </a>
  )
}

const ResourceLabel = resource =>
  <span>
    {resource.type === 'MediaEntry' ? 'den Eintrag' : 'das Set'}{' '}
    <ResourceLink {...resource} />
  </span>

const ResourceLabelPlural = ({ type }) =>
  <span>
    {type === 'MediaEntry' ? 'Eintr\xE4ge' : 'Sets'}
  </span>

// string helper, truncates long strings in the middle (better for visual comparisons)
function truncateMiddle (
  string,
  { length = 24, omission = '\u2026', raw = false }
) {
  if (!isString(string)) throw new TypeError('Not a String!')
  const symbols = Array.from(trimString(string))

  // unicode-safe split!
  if (symbols.length <= length) return symbols.join('')

  const maxLength = length - omission.length
  let [start, end] = [Math.ceil(maxLength / 2), Math.floor(maxLength / 2)]

  const result = [
    symbols.slice(0, start).join(''),
    omission,
    symbols.slice(-end).join('')
  ]

  return raw ? result : result.join('')
}
