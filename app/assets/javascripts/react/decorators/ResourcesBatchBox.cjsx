React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
ResourceThumbnail = require('../decorators/ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'ResourcesBatchBox'
  propTypes:
    resources: React.PropTypes.array.isRequired
    authToken: React.PropTypes.string.isRequired

  render: ({resources, authToken} = @props) ->
    <div className="bordered ui-container midtone rounded-right rounded-bottom mbm">
      <div className="ui-resources-selection">
        <div className="ui-toolbar inverted ui-container pvx phs rounded-top">
          <h2 className="ui-toolbar-header">
            {resources.length + ' ' + t('meta_data_batch_items_selected')}
          </h2>
        </div>
        <div className="ui-resources-media">
          <div className="ui-resources-holder pal">
            <ul className="grid ui-resources">
              {f.map resources, (resource) ->
                <ResourceThumbnail elm={'li'}
                  key={resource.uuid}
                  get={resource}
                  authToken={authToken}/>
              }
            </ul>
          </div>
        </div>
      </div>
    </div>
