import React from 'react'
import t from '../../lib/i18n-translate.js'
import TagCloud from '../ui-components/TagCloud.jsx'
import { isEmpty } from '../../lib/utils.js'

const DashboardSectionKeywords = ({ section, sectionResources }) => {
  const keywords = sectionResources.map(keyword => {
    return {
      children: keyword.label + ' ',
      href: keyword.url,
      count: keyword.usage_count
    }
  })

  return (
    <div id={section.id}>
      <div className="ui-resources-header">
        <h2 className="title-l ui-resources-title">{section.title}</h2>
        {isEmpty(keywords) ? (
          <span style={{ marginLeft: '10px' }}>{t('dashboard_none_exist')}</span>
        ) : (
          <a className="strong" href={section.href}>
            {t('dashboard_show_all')}
          </a>
        )}
      </div>
      {!isEmpty(keywords) && (
        <div className="ui-container pbh" style={{ paddingTop: '15px' }}>
          <TagCloud mod="label" list={keywords} />
        </div>
      )}
    </div>
  )
}

export default DashboardSectionKeywords
module.exports = DashboardSectionKeywords
