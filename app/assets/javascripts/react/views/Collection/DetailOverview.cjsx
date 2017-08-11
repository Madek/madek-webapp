React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/i18n-translate.js')
classnames = require('classnames')

MetaDataList = require('../../decorators/MetaDataList.cjsx')
ResourceShowOverview = require('../../templates/ResourceShowOverview.cjsx')
TabContent = require('../TabContent.cjsx')

SimpleResourceThumbnail = require('../../decorators/SimpleResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'CollectionDetailOverview'

  render: ({authToken, get} = @props) ->
    # NOTE: there is only 1 context (summary) allowed/possible for Sets!
    summary_context = get.summary_meta_data

    overview =
      content: <MetaDataList list={summary_context}
                type='table' showTitle={false} showFallback={true}/>
      preview: (
        <div className='ui-set-preview'>
          <SimpleResourceThumbnail type={get.type} title={get.title}
            authors_pretty={get.authors_pretty} image_url={get.image_url} />
        </div>
      )

    <div className="bright  pal rounded-top-right ui-container">
      <ResourceShowOverview {...overview}/>
    </div>
