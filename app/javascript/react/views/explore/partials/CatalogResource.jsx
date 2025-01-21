/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'lodash'
import CatalogThumbnail from './CatalogThumbnail.jsx'
import t from '../../../../lib/i18n-translate.js'

module.exports = createReactClass({
  displayName: 'CatalogResource',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { resource } = param
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
          {f.map(resource.examples.meta_key_values.values, (example, index) => {
            const { label } = example
            let comma = ''
            if (index < f.size(resource.examples.meta_key_values.values) - 1) {
              comma = <span style={{ marginRight: '5px' }}>,</span>
            }

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
})
