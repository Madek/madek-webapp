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
MetaDataByListing = require('../decorators/MetaDataByListing.cjsx')
TagCloud = require('../ui-components/TagCloud.cjsx')
resourceName = require('../lib/decorate-resource-names.coffee')


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
              <div className="bright pal rounded-bottom rounded-top-right ui-container">
                {
                  if get.logged_in
                    <div className='col1of3'>
                      <div className='ui-container prm'>
                        <h3 className='title-l separated mbm'>{t('resource_last_changes')}</h3>
                        {
                          if f.isEmpty(get.edit_sessions)
                            <div>{t('resource_last_changes_empty')}</div>
                          else
                            <div className="ui-metadata-box">
                              <table className="borderless">
                                <tbody>
                                  {
                                    f.map(get.edit_sessions, (edit_session) ->
                                      return if not edit_session.user
                                      list = [{
                                        href: edit_session.user.url
                                        children: resourceName(edit_session.user)
                                        key:  edit_session.user.uuid
                                      }]
                                      <tr>
                                        <td className="ui-summary-label">{edit_session.change_date}</td>
                                        <td className="ui-summary-content">
                                          <TagCloud mod='person' mods='small' list={list}></TagCloud>
                                        </td>
                                      </tr>
                                    )
                                  }
                                </tbody>
                              </table>
                            </div>
                        }
                      </div>
                    </div>
                }
                <div className='col2of3'>
                  <div className="ui-container plm">
                    <MetaDataByListing list={get.all_meta_data} />
                  </div>
                </div>
              </div>
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
