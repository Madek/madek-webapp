import React from 'react'
import Keyword from '../../../ui-components/Keyword.jsx'
import CatalogResourceList from './CatalogResourceList.jsx'
import ThumbnailResourceList from './ThumbnailResourceList.jsx'
import t from '../../../../lib/i18n-translate.js'

const ResourcesSection = ({ section, authToken }) => {
  return (
    <div className="ui-resources-holder pal" id={section.id}>
      {section.show_title && (
        <div className="ui-resources-header">
          <h2 className="title-l ui-resource-title">
            {section.data.title}
            {section.show_all_link && (
              <a className="strong" href={section.data.url}>
                {section.show_all_text || t('resources_section_show_all')}
              </a>
            )}
          </h2>
        </div>
      )}
      {section.type === 'catalog' || section.type === 'catalog_category' ? (
        <CatalogResourceList resources={section.data.list.resources} authToken={authToken} />
      ) : section.type === 'thumbnail' ? (
        <ThumbnailResourceList resources={section.data.list.resources} authToken={authToken} />
      ) : section.type === 'keyword' ? (
        <ul className="ui-tag-cloud" style={{ marginBottom: '40px' }}>
          {section.data.list.map((resource, n) => (
            <Keyword
              key={`key_${n}`}
              label={resource.keyword.label}
              hrefUrl={resource.keyword.url}
              count={resource.keyword.usage_count}
            />
          ))}
        </ul>
      ) : section.type === 'vocabularies' ? (
        <ul className="ui-tag-cloud">
          {section.data.list.map((resource, n) => {
            const isNotLast = n < section.data.list.length - 1
            const comma = isNotLast ? <span style={{ marginRight: '5px' }}>,</span> : null

            return (
              <span key={n}>
                <a href={resource.url} style={{ color: '#4c4c4c', fontSize: '14px' }}>
                  {resource.label}
                </a>
                {comma}
              </span>
            )
          })}
        </ul>
      ) : (
        <ul className="grid ui-resources" />
      )}
    </div>
  )
}

export default ResourcesSection
module.exports = ResourcesSection
