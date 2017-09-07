React = require('react')
f = require('active-lodash')
Keyword = require('../../../ui-components/Keyword.cjsx')
CatalogResource = require('./CatalogResource.cjsx')
WorthThumbnail = require('./WorthThumbnail.cjsx')
ResourceThumbnail = require('../../../decorators/ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'ResourcesSection'
  render: ({section, authToken} = @props)->
    <div className='ui-resources-holder pal' id={section.id}>
      {
        if section.show_title
          <div className='ui-resources-header'>
            <h2 className='title-l ui-resource-title'>
              {section.data.title}
              {if section.show_all_link
                <a className='strong' href={section.data.url}>
                  {
                    if section.show_all_text
                      section.show_all_text
                    else
                      'Alle anzeigen'
                  }
                </a>
              }
            </h2>
          </div>
      }
        {
          if section.type == 'catalog' or section.type == 'catalog_category'
            <ul className='grid ui-resources' style={{marginBottom: '40px', marginTop: '0px'}}>
            {
              f.map section.data.list, (resource, n) =>
                <CatalogResource key={'key_' + n} resource={resource} />
            }
            </ul>
          else if section.type == 'thumbnail'
            <ul className='grid ui-resources'>
            {
              f.map section.data.list.resources, (resource, n) ->
                <ResourceThumbnail key={'key_' + n} elm='div' get={resource} authToken={authToken} />
            }
            </ul>
          else if section.type == 'keyword'
            <ul className='ui-tag-cloud' style={{marginBottom: '40px'}}>
            {
              f.map section.data.list, (resource, n) ->
                <Keyword key={'key_' + n} label={resource.keyword.label}
                  hrefUrl={resource.keyword.url} count={resource.keyword.usage_count} />
            }
            </ul>
          else if section.type == 'vocabularies'
            <ul className='ui-tag-cloud'>
            {
              f.map section.data.list, (resource, n) ->
                comma = ''
                if n < f.size(section.data.list) - 1
                  comma = <span style={{marginRight: '5px'}}>,</span>

                <span>
                  <a href={resource.url} style={{color: '#4c4c4c', fontSize: '14px'}}>
                    {resource.label}
                  </a>
                  {comma}
                </span>
            }
            </ul>
          else
            <ul className='grid ui-resources' />
        }
    </div>
