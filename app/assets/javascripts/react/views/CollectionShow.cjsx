React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
parseUrl = require('url').parse
t = require('../../lib/string-translation.js')('de')

RightsManagement = require('../templates/ResourcePermissions.cjsx')
CollectionRelations = require('./Collection/Relations.cjsx')
CollectionMetadata = require('./Collection/Metadata.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
Tabs = require('./Tabs.cjsx')
Tab = require('./Tab.cjsx')
PageContent = require('./PageContent.cjsx')
TabContent = require('./TabContent.cjsx')
CollectionDetailOverview = require('./Collection/DetailOverview.cjsx')
CollectionDetailAdditional = require('./Collection/DetailAdditional.cjsx')
HighlightedContents = require('./Collection/HighlightedContents.cjsx')
MediaEntryHeader = require('./MediaEntryHeader.cjsx')

tabIdByLocation = (tabs, location) ->
  # NOTE: some tabs have subroutes (permissions/edit), ignore those:
  # (could also compare with `f.startsWith(path, tab.href)`,
  # but that would only work if main tab is always first (and reversed list is searched)
  path = parseUrl(location).pathname.replace(/\/edit(\/)?$/, '')
  tab = f.find(tabs, {href: path})
  f.get(tab, 'id')

module.exports = React.createClass
  displayName: 'CollectionShow'

  # NOTE: setting active by pathname because will work as is with a router
  getInitialState: () -> {
    isMounted: false
    activeTab: tabIdByLocation(@props.get.tabs, @props.for_url)
  }

  componentDidMount: () ->
    @setState(isMounted: true)

  componentWillReceiveProps: (nextProps)->
    return if nextProps.for_url is @props.for_url
    @setState(activeTab: tabIdByLocation(@props.get.tabs, @props.for_url))

  _setActiveTab: (currentLocation) ->
    if (tabId = tabIdByLocation(@props.get.tabs, currentLocation))
      @setState(activeTab: tabId) unless (tabId == @state.activeTab)

  render: ({authToken, get} = @props, {isMounted, activeTab} = @state) ->
    <PageContent>
      <MediaEntryHeader authToken={authToken} get={get.header} showModal={@props.showModal}
        async={isMounted} modalAction={'select_collection'}/>

      <Tabs>
        {f.map get.tabs, (tab) =>
          <Tab key={tab.id}
            href={tab.href} onClick={@_onTabClick}
            iconType={tab.icon_type} privacyStatus={get.privacy_status}
            label={tab.label} active={tab.id == activeTab} />
        }
      </Tabs>
        {switch activeTab

          when 'relations'
            <CollectionRelations get={get} authToken={authToken} />

          when 'more_data'
            <TabContent>
              <CollectionMetadata get={get} authToken={authToken} />
            </TabContent>

          when 'permissions'
            <TabContent>
              <div className="bright pal rounded-bottom rounded-top-right ui-container">
                <RightsManagement get={get.permissions} />
              </div>
            </TabContent>

          # main tab:
          else
            <TabContent>
              <CollectionDetailOverview get={get} authToken={authToken} />
              <HighlightedContents get={get} authToken={authToken} />
              <CollectionDetailAdditional get={get} authToken={authToken} />
            </TabContent>
          }
    </PageContent>
