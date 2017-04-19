React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
parseUrl = require('url').parse
t = require('../../lib/string-translation.js')('de')

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



module.exports = React.createClass
  displayName: 'MediaEntryHeaderWithModal'

  getInitialState: () -> {
    selectCollectionModal: false
  }

  _onClick: (asyncAction) ->
    if asyncAction == 'select_collection'
      @setState(selectCollectionModal: true)


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

          getUrl = get.header.url + '/select_collection?___sparse={collection_selection":{}}'
          <AsyncModal get={get.collection_selection} getUrl={getUrl}
              contentForGet={contentForGet} extractGet={extractGet} />
      }

      <MediaEntryHeader authToken={authToken} get={get.header}
        async={true}
        onClick={@_onClick}/>

    </div>
