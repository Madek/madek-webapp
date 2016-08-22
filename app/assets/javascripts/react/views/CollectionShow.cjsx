React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
RailsForm = require('../lib/forms/rails-form.cjsx')
MediaResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
RightsManagement = require('../templates//ResourcePermissions.cjsx')
CollectionRelations = require('./Collection/Relations.cjsx')
CollectionMetadata = require('./Collection/Metadata.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
Tabs = require('./Tabs.cjsx')
Tab = require('./Tab.cjsx')
PageContent = require('./PageContent.cjsx')
classnames = require('classnames')
TabContent = require('./TabContent.cjsx')
CollectionDetailOverview = require('./Collection/DetailOverview.cjsx')
CollectionDetailAdditional = require('./Collection/DetailAdditional.cjsx')
HighlightedContents = require('./Collection/HighlightedContents.cjsx')
MediaEntryHeader = require('./MediaEntryHeader.cjsx')


module.exports = React.createClass
  displayName: 'CollectionShow'

  getInitialState: () -> { mounted: false }
  componentDidMount: () -> @setState(mounted: true)

  render: ({authToken, get} = @props) ->
    <PageContent>
      <MediaEntryHeader authToken={authToken} get={get.header} showModal={@props.showModal}
        async={@state.mounted} modalAction={'select_collection'}/>

      <Tabs>
        {f.map get.tabs, (tab) ->
          <Tab href={tab.href} key={tab.href}
            iconType={tab.icon_type} privacyStatus={get.privacy_status}
            label={tab.label} active={tab.id == get.active_tab} />
        }
      </Tabs>
        {switch get.active_tab

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
