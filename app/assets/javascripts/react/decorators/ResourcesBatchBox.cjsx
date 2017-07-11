React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
ResourceThumbnail = require('../decorators/ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'ResourcesBatchBox'
  propTypes:
    resources: React.PropTypes.array.isRequired
    authToken: React.PropTypes.string.isRequired

  render: ({resources, authToken, total} = @props) ->
    <div className="bordered ui-container midtone rounded-right rounded-bottom mbm">
      <div className="ui-resources-selection">
        <div className="ui-toolbar inverted ui-container pvx phs rounded-top">
          <h2 className="ui-toolbar-header">
            {total + ' ' + t('meta_data_batch_items_selected')}
          </h2>
        </div>
        <div style={{overflow: 'hidden'}} className="ui-resources-media">
          <div className="ui-resources-holder pal">
            <ul className="grid ui-resources">
              {f.map resources, (resource) ->
                <ResourceThumbnail elm={'li'}
                  key={resource.uuid}
                  get={resource}
                  authToken={authToken}/>
              }

              {
                if resources.length < total
                  style = {
                    paddingTop: '50px',
                    paddingLeft: '20px',
                    display: 'block',
                    float: 'left',
                    fontSize: '24px'
                  }

                  text = '+' + (total - resources.length) + ' weitere'

                  <li style={style}>
                    {'+' + (total - resources.length)}
                    <br />
                    {'weitere'}
                  </li>

              }

            </ul>
          </div>
        </div>
      </div>
    </div>
