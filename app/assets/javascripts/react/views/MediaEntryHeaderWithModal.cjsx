React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
parseUrl = require('url').parse
buildUrl = require('url').format
t = require('../../lib/i18n-translate.js')

RightsManagement = require('../templates/ResourcePermissions.cjsx')
CollectionRelations = require('./Collection/Relations.cjsx')
RelationResources = require('./Collection/RelationResources.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
Tabs = require('./Tabs.cjsx')
Tab = require('./Tab.cjsx')
PageContent = require('./PageContent.cjsx')
TabContent = require('./TabContent.cjsx')
CollectionDetailOverview = require('./Collection/DetailOverview.cjsx')
CollectionDetailAdditional = require('./Collection/DetailAdditional.cjsx')
AsyncModal = require('./Collection/AsyncModal.cjsx')
SelectCollection = require('./Collection/SelectCollection.cjsx')
HighlightedContents = require('./Collection/HighlightedContents.cjsx')
MediaEntryHeader = require('./MediaEntryHeader.cjsx')
MetaDataByListing = require('../decorators/MetaDataByListing.cjsx')
TagCloud = require('../ui-components/TagCloud.cjsx')
resourceName = require('../lib/decorate-resource-names.coffee')
UsageData = require('../decorators/UsageData.cjsx')
Share = require('./Shared/Share.cjsx')



module.exports = React.createClass
  displayName: 'MediaEntryHeaderWithModal'

  getInitialState: () -> {
    selectCollectionModal: false,
    shareModal: false
  }

  _onClick: (asyncAction) ->
    if asyncAction == 'select_collection'
      @setState(selectCollectionModal: true)
    else if asyncAction == 'share'
      @setState(shareModal: true)


  render: ({authToken, get} = @props) ->

    <div style={{margin: '0px', padding: '0px'}}>

      {
        if @state.selectCollectionModal

          onClose = () =>
            @setState(selectCollectionModal: false)

          contentForGet = (get) =>
            <SelectCollection
              get={get} async={true}
              authToken={@props.authToken} onClose={onClose} />

          extractGet = (json) =>
            json.collection_selection

          getUrl = () =>
            parsedUrl = parseUrl(get.header.select_collection_url, true)
            delete parsedUrl.search
            parsedUrl.query['___sparse'] = '{collection_selection:{}}'
            buildUrl(parsedUrl)

          <AsyncModal get={get.collection_selection} getUrl={getUrl()}
              contentForGet={contentForGet} extractGet={extractGet} />
      }

      {
        if @state.shareModal

          onClose = () =>
            @setState(shareModal: false)

          contentForGet = (get) =>
            <Share
              fullPage={false}
              get={get} async={true}
              authToken={@props.authToken} onClose={onClose} />

          extractGet = (json) =>
            json

          getUrl = get.header.share_url
          <AsyncModal get={null} getUrl={getUrl} widthInPixel={800}
              contentForGet={contentForGet} extractGet={extractGet} />

      }

      <MediaEntryHeader authToken={authToken} get={get.header}
        async={true}
        onClick={@_onClick}/>

    </div>
