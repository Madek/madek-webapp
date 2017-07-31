React = require('react')
f = require('lodash')
CatalogThumbnail = require('./CatalogThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'CatalogResource'

  render: ({resource} = @props)->
    <li className="ui-resource" style={{display: 'table'}}>
      <CatalogThumbnail imageUrl={resource.image_url} hrefUrl={resource.url}
        usageCount={resource.usage_count} />
      <div style={{display: 'table-cell', paddingLeft: '15px', verticalAlign: 'bottom', paddingBottom: '48px'}}>
        <div className='ui-resources-header'>
          <h2 className='title-l ui-resource-title' style={{display: 'inline-block'}}>
            {resource.label}
          </h2>
          <a className='strong' href={resource.url}>
            {'Weitere anzeigen'}
          </a>
        </div>
        {
          f.map(resource.examples.meta_key_values.values, (example, index) =>
            <span style={{display: 'inline-block', whiteSpace: 'nowrap', fontSize: '14px', textOverflow: 'ellipsis', maxWidth: '200px', overflow: 'hidden'}}>
              <a href={example.url} style={{color: '#4c4c4c'}}>
                {example.label + ' - '}
              </a>
            </span>

          )
        }

      </div>
    </li>
