/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import Keyword from '../../../ui-components/Keyword.jsx'
import CatalogResource from './CatalogResource.jsx'
import ResourceThumbnail from '../../../decorators/ResourceThumbnail.jsx'
import t from '../../../../lib/i18n-translate'

module.exports = createReactClass({
  displayName: 'ResourcesSection',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { section, authToken } = param
    return (
      <div className="ui-resources-holder pal" id={section.id}>
        {section.show_title ? (
          <div className="ui-resources-header">
            <h2 className="title-l ui-resource-title">
              {section.data.title}
              {section.show_all_link ? (
                <a className="strong" href={section.data.url}>
                  {section.show_all_text ? section.show_all_text : t('resources_section_show_all')}
                </a>
              ) : undefined}
            </h2>
          </div>
        ) : undefined}
        {section.type === 'catalog' || section.type === 'catalog_category' ? (
          <ul className="grid ui-resources" style={{ marginBottom: '40px', marginTop: '0px' }}>
            {f.map(section.data.list, (resource, n) => {
              return <CatalogResource key={`key_${n}`} resource={resource} />
            })}
          </ul>
        ) : section.type === 'thumbnail' ? (
          <ul className="grid ui-resources">
            {f.map(section.data.list.resources, (resource, n) => (
              <ResourceThumbnail key={`key_${n}`} elm="div" get={resource} authToken={authToken} />
            ))}
          </ul>
        ) : section.type === 'keyword' ? (
          <ul className="ui-tag-cloud" style={{ marginBottom: '40px' }}>
            {f.map(section.data.list, (resource, n) => (
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
            {f.map(section.data.list, function (resource, n) {
              let comma = ''
              if (n < f.size(section.data.list) - 1) {
                comma = <span style={{ marginRight: '5px' }}>,</span>
              }

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
})
