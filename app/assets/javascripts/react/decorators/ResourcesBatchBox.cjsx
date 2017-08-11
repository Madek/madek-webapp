React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
ResourceThumbnail = require('../decorators/ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'ResourcesBatchBox'
  propTypes:
    resources: React.PropTypes.array.isRequired
    authToken: React.PropTypes.string.isRequired

  render: ({resources, authToken, batchCount, counts} = @props) ->

    <div className="bordered ui-container midtone rounded-right rounded-bottom mbm">
      <div className="ui-resources-selection">
        <div className="ui-toolbar inverted ui-container pvx phs rounded-top">
          <h2 className="ui-toolbar-header">
            {batchCount + ' ' + t('meta_data_batch_items_selected')}
            {
              if counts && counts.authorized_resources < counts.all_resources
                <span style={{color: '#e5b100'}}>
                  {' ' + t('meta_data_batch_some_ignored_1')}
                  {(counts.all_resources - counts.authorized_resources)}
                  {t('meta_data_batch_some_ignored_2')}
                </span>
            }
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
                if resources.length < batchCount
                  style = {
                    paddingTop: '50px',
                    paddingLeft: '20px',
                    display: 'block',
                    float: 'left',
                    fontSize: '24px'
                  }

                  text = '+' + (batchCount - resources.length) + ' ' + t('meta_data_batch_more')

                  <li style={style}>
                    {'+' + (batchCount - resources.length)}
                    <br />
                    {t('meta_data_batch_more')}
                  </li>

              }

            </ul>
          </div>
        </div>
      </div>
    </div>
