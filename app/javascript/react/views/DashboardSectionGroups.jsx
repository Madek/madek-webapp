import React from 'react'
import t from '../../lib/i18n-translate.js'
import TagCloud from '../ui-components/TagCloud.jsx'
import { isEmpty } from '../../lib/utils.js'

const DashboardSectionGroups = ({ section, sectionResources }) => {
  const groupTypeConfigs = {
    internal: t('internal_groups'),
    delegations: t('responsibility_groups'),
    authentication: t('authentication_groups'),
    external: t('external_groups')
  }

  const groupTypes = Object.entries(groupTypeConfigs).map(([type, label]) => {
    const groups = sectionResources[type]
      ? sectionResources[type].map(entry => ({
          children: entry.detailed_name,
          href: entry.url
        }))
      : []
    return { type, label, list: groups }
  })

  return (
    <div id={section.id}>
      <div className="ui-resources-header">
        <h2 className="title-l ui-resources-title">{section.title}</h2>
        <a className="strong" href={section.href}>
          {t('dashboard_show_all')}
        </a>
      </div>
      <div className="ui-container pbl">
        {groupTypes.map(({ type, label, list }) => {
          if (list) {
            return (
              <label className="ui-form-group columned phn" key={type}>
                <div className="form-label">{label}</div>
                {isEmpty(list) ? (
                  <div className="form-item" style={{ paddingTop: '5px' }}>
                    {t('dashboard_none_exist')}
                  </div>
                ) : (
                  <div className="form-item">
                    <TagCloud mod="label" list={list} />
                  </div>
                )}
              </label>
            )
          }
          return null
        })}
      </div>
    </div>
  )
}

export default DashboardSectionGroups
module.exports = DashboardSectionGroups
