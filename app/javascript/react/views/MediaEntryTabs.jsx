import React, { useState, useEffect } from 'react'
import cx from 'classnames'
import MediaEntryPrivacyStatusIcon from './MediaEntryPrivacyStatusIcon.jsx'
import { parse as parseUrl } from 'url'

const parseUrlState = location => {
  const urlParts = parseUrl(location).pathname.split('/').slice(1)
  if (urlParts.length < 3) {
    return { action: 'show', argument: null }
  } else {
    return {
      action: urlParts[2],
      argument: urlParts.length > 3 ? urlParts[3] : undefined
    }
  }
}

const activeTabId = urlState => urlState.action

const MediaEntryTabs = ({ get, for_url }) => {
  const [urlState, setUrlState] = useState(parseUrlState(for_url))

  useEffect(() => {
    setUrlState(parseUrlState(for_url))
  }, [for_url])

  const media_entry_path = get.url

  const tabs = Object.fromEntries(
    get.tabs.map(tab => {
      const path = tab.href ? tab.href : media_entry_path

      const icon =
        tab.icon_type === 'privacy_status_icon' ? <MediaEntryPrivacyStatusIcon get={get} /> : null

      return [path, { ...tab, icon }]
    })
  )

  return (
    <ul className="ui-tabs large">
      {Object.entries(tabs).map(([path, tab]) => {
        const active = tab.id === activeTabId(urlState)
        const classes = cx('ui-tabs-item', { active: active })

        return (
          <li key={tab.id} className={classes}>
            <a href={path}>
              {tab.icon}
              {` ${tab.title} `}
            </a>
          </li>
        )
      })}
    </ul>
  )
}

export default MediaEntryTabs
module.exports = MediaEntryTabs
