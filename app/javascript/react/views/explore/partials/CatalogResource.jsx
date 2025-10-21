import React from 'react'
import CatalogThumbnail from './CatalogThumbnail.jsx'
import t from '../../../../lib/i18n-translate.js'

const CatalogResource = ({ resource }) => {
  return (
    <li className="ui-resource" style={{ display: 'table' }}>
      <CatalogThumbnail
        imageUrl={resource.image_url}
        hrefUrl={resource.url}
        usageCount={resource.usage_count}
      />
      <div
        style={{
          display: 'table-cell',
          padding: '15px',
          verticalAlign: 'top',
          paddingBottom: '48px'
        }}>
        <div className="ui-resources-header">
          <h2 className="title-l ui-resource-title" style={{ display: 'inline-block' }}>
            {resource.label}
          </h2>
          <a className="strong" href={resource.url}>
            {t('explore_show_more')}
          </a>
        </div>
        {resource.examples.meta_key_values.values.map((example, index) => {
          const { label } = example
          const isNotLast = index < resource.examples.meta_key_values.values.length - 1
          const comma = isNotLast ? <span style={{ marginRight: '5px' }}>,</span> : null

          return (
            <span
              key={index}
              style={{ display: 'inline-block', whiteSpace: 'nowrap', fontSize: '14px' }}>
              <a href={example.url} style={{ color: '#4c4c4c' }}>
                {label}
              </a>
              {comma}
            </span>
          )
        })}
      </div>
    </li>
  )
}

export default CatalogResource
module.exports = CatalogResource
