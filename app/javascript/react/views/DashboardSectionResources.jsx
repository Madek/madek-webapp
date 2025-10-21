import React, { useState } from 'react'
import { parse as parseUrl, format as buildUrl } from 'url'
import t from '../../lib/i18n-translate.js'
import AsyncDashboardSection from '../lib/AsyncDashboardSection.jsx'
import Preloader from '../ui-components/Preloader.jsx'

const DashboardSectionResources = ({ section, url }) => {
  const [result, setResult] = useState(null)

  const is_clipboard = section.id === 'clipboard'
  const mods = ['unpaginated']
  const fallback = section['is_empty?'] ? true : false

  const initial_props = {
    mods,
    fallback,
    enableOrdering: true,
    enableOrderByTitle: true,
    initial: {
      show_filter: false,
      is_clipboard
    }
  }

  const parsedUrl = parseUrl(url, true)
  delete parsedUrl.search
  parsedUrl.query['___sparse'] = `{"user_dashboard":{"${section.id}":{}}}`

  const handleCallback = callbackResult => {
    setResult(callbackResult)
  }

  return (
    <div id={section.id}>
      <div className="ui-resources-header">
        <h2 className="title-l ui-resources-title">{section.title}</h2>
        {result === null ? (
          <Preloader
            mods="small"
            style={{
              width: '100px',
              height: '10px',
              marginTop: '10px',
              marginLeft: '30px',
              display: 'inline-block'
            }}
          />
        ) : result === 'empty' ? (
          <span style={{ marginLeft: '10px' }}>{t('dashboard_none_exist')}</span>
        ) : (
          <a className="strong" href={section.href}>
            {t('dashboard_show_all')}
          </a>
        )}
      </div>
      <AsyncDashboardSection
        url={buildUrl(parsedUrl)}
        json_path={`user_dashboard.${section.id}`}
        fallback_url={section.href}
        initial_props={initial_props}
        callback={handleCallback}
        renderEmpty={result === null}
      />
    </div>
  )
}

export default DashboardSectionResources
module.exports = DashboardSectionResources
