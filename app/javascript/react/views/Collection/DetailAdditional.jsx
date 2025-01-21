/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import MediaResourcesBox from '../../decorators/MediaResourcesBox.jsx'

module.exports = createReactClass({
  displayName: 'CollectionDetailAdditional',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get, authToken } = param
    const contextId = f.startsWith(get.active_tab, 'context_')
      ? f.get(get, 'context_meta_data.context.uuid')
      : f.get(get, 'summary_meta_data.context.uuid')

    const collectionData = {
      uuid: get.uuid,
      layout: get.layout,
      editable: get.editable,
      order: get.sorting,
      position_changeable: get.position_changeable,
      url: get.url,
      batchEditUrl: get.batch_edit_url,
      changePositionUrl: get.change_position_url,
      newCollectionUrl: get.new_collection_url,
      contextId,
      defaultContextId:
        f.get(get, 'default_context_id') || f.get(get, 'summary_meta_data.context.uuid'),
      typeFilter: get.type_filter,
      defaultTypeFilter: get.default_type_filter,
      defaultResourceType: get.default_resource_type
    }

    return (
      <div className="ui-container rounded-bottom">
        <MediaResourcesBox
          get={get.child_media_resources}
          authToken={authToken}
          initial={{ show_filter: true }}
          mods={[{ bordered: false }, 'rounded-bottom']}
          collectionData={collectionData}
          resourceTypeSwitcherConfig={{ showAll: true }}
          enableOrdering={true}
          enableOrderByTitle={true}
          enableOrderByManual={true}
          showAllButton={true}
          showAddSetButton={true}
        />
      </div>
    )
  }
})
