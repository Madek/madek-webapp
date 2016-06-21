React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
classnames = require('classnames')

MetaDataList = require('../../decorators/MetaDataList.cjsx')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
ResourceShowOverview = require('../../templates//ResourceShowOverview.cjsx')
TabContent = require('../TabContent.cjsx')

module.exports = React.createClass
  displayName: 'CollectionDetailOverview'

  render: ({authToken, get} = @props) ->
    # NOTE: there is only 1 context (summary) allowed/possible for Sets!
    summary_context = get.meta_data.by_context[0]

    overview =
      content: <MetaDataList list={summary_context}
                type='table' showTitle={false} showFallback={false}/>
      preview: <Preview title={get.title} alt='(Unbekannt)' src={get.image_url} />

    <div className="bright  pal rounded-top-right ui-container">
      <ResourceShowOverview {...overview}/>
    </div>

Preview = React.createClass
  displayName: 'Preview'
  render: ({title, alt, src} = @props) ->
    <div className="media-set ui-thumbnail">
      <span className="ui-thumbnail-image-wrapper" title={title}>
        <div className="ui-thumbnail-image-holder">
          <div className="ui-thumbnail-table-image-holder">
            <div className="ui-thumbnail-cell-image-holder">
              <div className="ui-thumbnail-inner-image-holder">
                <img alt={alt} className="ui-thumbnail-image" src={src}></img>
              </div>
            </div>
          </div>
        </div>
      </span>
    </div>
