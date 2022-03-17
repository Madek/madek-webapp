React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
classnames = require('classnames')
t = require('../../../lib/i18n-translate.js')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
TabContent = require('../TabContent.cjsx')
LoadXhr = require('../../../lib/load-xhr.coffee')
resourceTypeSwitcher = require('../../lib/resource-type-switcher.cjsx').resourceTypeSwitcher
libUrl = require('url')

module.exports = React.createClass
  displayName: 'CollectionDetailAdditional'

  render: ({get, authToken} = @props) ->
    contextId = if f.startsWith(get.active_tab, 'context_')
      f.get(get, 'context_meta_data.context.uuid')
    else
      f.get(get, 'summary_meta_data.context.uuid')

    collectionData =
      uuid: get.uuid
      layout: get.layout
      editable: get.editable
      order: get.sorting
      position_changeable: get.position_changeable
      url: get.url
      batchEditUrl: get.batch_edit_url
      changePositionUrl: get.change_position_url
      newCollectionUrl: get.new_collection_url
      contextId: contextId
      defaultContextId: f.get(get, 'default_context_id') or f.get(get, 'summary_meta_data.context.uuid')

    renderSwitcher = (boxUrl) =>
      resourceTypeSwitcher(boxUrl, true, null)

    <div className="ui-container rounded-bottom">
      <MediaResourcesBox
        get={get.child_media_resources} authToken={authToken}
        initial={ { show_filter: true } } mods={ [ {bordered: false}, 'rounded-bottom' ] }
        collectionData={collectionData}
        renderSwitcher={renderSwitcher}
        enableOrdering={true}
        enableOrderByTitle={true}
        enableOrderByManual={true}
        showAllButton={true}
        showAddSetButton={true}
        />
    </div>
