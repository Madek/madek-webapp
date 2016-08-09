React = require('react')
f = require('active-lodash')
Keyword = require('../../../ui-components/Keyword.cjsx')
CatalogThumbnail = require('./CatalogThumbnail.cjsx')
WorthThumbnail = require('./WorthThumbnail.cjsx')
ResourceThumbnail = require('../../../decorators/ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'ResourcesSection'
  render: ({label, hrefUrl, showAllLink, section, authToken} = @props)->
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
        {
          if section.type == 'catalog' or section.type == 'catalog_category'
            <ul className="grid ui-resources">
            {
              f.map section.data.list, (resource, n) ->
                <CatalogThumbnail key={'key_' + n} usageCount={resource.usage_count} label={resource.label}
                  description={resource.description} imageUrl={resource.image_url} hrefUrl={resource.url} />
            }
            </ul>
          else if section.type == 'thumbnail'
            <ul className="grid ui-resources">
            {
              f.map section.data.list.resources, (resource, n) ->
                <ResourceThumbnail key={'key_' + n} elm='div' get={resource} authToken={authToken} />
            }
            </ul>
          else if section.type == 'keyword'
            <ul className="ui-tag-cloud">
            {
              f.map section.data.list, (resource, n) ->
                <Keyword key={'key_' + n} label={resource.keyword.label}
                  hrefUrl={resource.keyword.url} count={resource.keyword.usage_count} />
            }
            </ul>
          else
            <ul className="grid ui-resources" />
        }
    </div>
