React = require('react')
f = require('active-lodash')
t = require('../lib/string-translation.js')('de')
BatchFormResourceMetaData = require('./batch-form-resource-meta-data.cjsx')
Thumbnail = require('./ui-components/Thumbnail.cjsx')

module.exports = React.createClass
  displayName: 'BatchResourcesBox'

  render: ({get, authToken} = @props) ->
    <div className="bordered ui-container midtone rounded-right rounded-bottom mbm">
      <div className="ui-resources-selection">
        <div className="ui-toolbar inverted ui-container pvx phs rounded-top">
          <h2 className="ui-toolbar-header">
            {get.resources.resources.length + ' ' + t('meta_data_batch_items_selected')}
          </h2>
        </div>
        <div className="ui-resources-media">
          <div className="ui-resources-holder pal">
            <ul className="grid ui-resources">
              {f.map get.resources.resources, (resource) ->
                <ThumbnailWrapper key={resource.uuid} title={resource.title} authors={resource.authors_pretty}
                  hrefUrl={resource.url} imageUrl={resource.image_url} />
              }
            </ul>
          </div>
        </div>
      </div>
    </div>


ThumbnailWrapper = React.createClass
  displayName: 'ThumbnailWrapper'
  render: ({title, authors, imageUrl, hrefUrl} = @props) ->
    <li className="ui-resource not-loaded-contexts">
      <div className="ui-resource-body">
        <div className="ui-resource-thumbnail">
          <Thumbnail className="ui-thumbnail media-entry image"
            src={imageUrl} href={hrefUrl}
            meta={{ title: title, subtitle: authors}} />
        </div>
      </div>
    </li>
