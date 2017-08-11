React = require('react')
f = require('lodash')
CatalogThumbnail = require('./CatalogThumbnail.cjsx')
t = require('../../../../lib/i18n-translate.js')

module.exports = React.createClass
  displayName: 'CatalogResource'

  render: ({resource} = @props)->
    <li className="ui-resource" style={{display: 'table'}}>
      <CatalogThumbnail imageUrl={resource.image_url} hrefUrl={resource.url}
        usageCount={resource.usage_count} />
      <div style={{display: 'table-cell', padding: '15px', verticalAlign: 'top', paddingBottom: '48px'}}>
        <div className='ui-resources-header'>
          <h2 className='title-l ui-resource-title' style={{display: 'inline-block'}}>
            {resource.label}
          </h2>
          <a className='strong' href={resource.url}>
            {t('explore_show_more')}
          </a>
        </div>
        {
          f.map(resource.examples.meta_key_values.values, (example, index) =>

            label = example.label
            comma = ''
            if index < f.size(resource.examples.meta_key_values.values) - 1
              comma = <span style={{marginRight: '5px'}}>,</span>

            <span style={{display: 'inline-block', whiteSpace: 'nowrap', fontSize: '14px'}}>
              <a href={example.url} style={{color: '#4c4c4c'}}>
                {label}
              </a>
              {comma}
            </span>

          )
        }

      </div>
    </li>
