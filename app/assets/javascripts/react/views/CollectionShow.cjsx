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


parseUrlState = (location) ->
  urlParts = f.slice(parseUrl(location).pathname.split('/'), 1)
  if urlParts.length < 3
    { action: 'show', argument: null }
  else
    {
      action: urlParts[2]
      argument: urlParts[3] if urlParts.length > 3
    }

activeTabId = (urlState) ->
  if urlState.action == 'context'
    urlState.action + '/' + urlState.argument
  else
    urlState.action

contentTestId = (id) ->
  'set_tab_content_' + id

tabTestId = (id) ->
  'set_tab_' + id

module.exports = React.createClass
  displayName: 'CollectionShow'

  # NOTE: setting active by pathname because will work as is with a router
  getInitialState: () -> {
    isMounted: false
    urlState: parseUrlState(@props.for_url)
    selectCollectionModal: false
  }

  componentDidMount: () ->
    @setState(isMounted: true)

  componentWillReceiveProps: (nextProps)->
    return if nextProps.for_url is @props.for_url
    @setState(urlState: parseUrlState(@props.for_url))

  _onClick: (asyncAction) ->
    if asyncAction == 'select_collection'
      @setState(selectCollectionModal: true)


  render: ({authToken, get} = @props, {isMounted, urlState} = @state) ->

    <PageContent>

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
        async={isMounted}
        onClick={@_onClick}/>

      <Tabs>
        {f.map get.tabs, (tab) ->
          <Tab key={tab.id}
            href={tab.href} testId={tabTestId(tab.id)}
            iconType={tab.icon_type} privacyStatus={get.privacy_status}
            label={tab.label} active={tab.id == activeTabId(urlState)} />
        }
      </Tabs>
        {switch urlState.action

          when 'relations'
            switch get.action
              when 'relations'
                <CollectionRelations get={get} authToken={authToken}
                  testId={contentTestId('relations')} />
              when 'relation_parents'
                <RelationResources get={get} authToken={authToken} scope='parents'
                  testId={contentTestId('relations_parents')} />
              when 'relation_children'
                <RelationResources get={get} authToken={authToken} scope='children'
                  testId={contentTestId('relations_children')} />
              when 'relation_siblings'
                <RelationResources get={get} authToken={authToken} scope='siblings'
                  testId={contentTestId('relations_siblings')} />

          when 'usage_data'
            <TabContent testId={contentTestId('usage_data')}>
              <div className="bright pal rounded-bottom rounded-top-right ui-container">
                {
                  if get.logged_in
                    <UsageData get={get} />

                }
              </div>
            </TabContent>

          when 'more_data'
            <TabContent testId={contentTestId('more_data')}>
              <div className="bright pal rounded-bottom rounded-top-right ui-container">
                <div className="ui-container">
                  <h3 className='title-l mbl'>{t('media_entry_all_metadata_title')}</h3>
                  <MetaDataByListing list={get.all_meta_data} vocabLinks hideSeparator />
                </div>
              </div>
            </TabContent>

          when 'permissions'
            <TabContent testId={contentTestId('permissions')}>
              <div className="bright pal rounded-bottom rounded-top-right ui-container">
                <RightsManagement authToken={@props.authToken} get={get.permissions} />
              </div>
            </TabContent>

          when 'context'
            MetaDataList = require('../decorators/MetaDataList.cjsx')
            cx = require('classnames')

            <TabContent testId={contentTestId('context_' + urlState.argument)}>
              <div className="bright  pal rounded-top-right ui-container">
                <div className={cx('ui-resource-overview')}>

                  <MetaDataList list={get.context_meta_data}
                    type='table' showTitle={false} showFallback={true}/>

                </div>
              </div>
            </TabContent>

          # main tab:
          else
            <TabContent testId={contentTestId('show')}>
              <CollectionDetailOverview get={get} authToken={authToken} />
              <HighlightedContents get={get} authToken={authToken} />
              <CollectionDetailAdditional get={get} authToken={authToken} />
            </TabContent>
          }
    </PageContent>
