React = require('react')
f = require('active-lodash')
Keyword = require('../../../ui-components/Keyword.cjsx')
CatalogThumbnail = require('./CatalogThumbnail.cjsx')
WorthThumbnail = require('./WorthThumbnail.cjsx')


module.exports = React.createClass
  displayName: 'ResourcesSection'
  render: ({label, hrefUrl, showAllLink, section} = @props)->
    <div className="ui-resources-holder pal" id="catalog">
      <div className="ui-resources-header">
        <h2 className="title-l ui-resource-title">
          {label}
          {if showAllLink
            <a className="strong" href={hrefUrl}>
              Alle anzeigen
            </a>
          }
        </h2>
      </div>
      <ul className="grid ui-resources">
        {
          if section.type == 'catalog' or section.type == 'catalog_category'
            f.map section.data.list, (resource, n) ->
              <CatalogThumbnail key={'key_' + n} usageCount={resource.usage_count} label={resource.label}
                description={resource.description} imageUrl={resource.image_url} hrefUrl={resource.url} />
          else if section.type == 'thumbnail'
            f.map section.data.list.resources, (resource, n) ->
              <WorthThumbnail key={'key_' + n} author={resource.owner_pretty} label={resource.title}
                imageUrl={resource.image_url} hrefUrl={resource.url} />
          else if section.type == 'keyword'
            f.map section.data.list, (resource, n) ->
              <Keyword key={'key_' + n} label={resource.keyword.label}
                hrefUrl={resource.keyword.url} count={resource.keyword.usage_count} />
          else
            []
        }
      </ul>
    </div>
