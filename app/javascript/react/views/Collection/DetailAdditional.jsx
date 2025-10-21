import React from 'react'
import MediaResourcesBox from '../../decorators/MediaResourcesBox.jsx'
import { get as getPath } from '../../../lib/utils.js'

const CollectionDetailAdditional = ({ get, authToken }) => {
  const contextId =
    get.active_tab && get.active_tab.startsWith('context_')
      ? getPath(get, 'context_meta_data.context.uuid', null)
      : getPath(get, 'summary_meta_data.context.uuid', null)

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
      getPath(get, 'default_context_id', null) ||
      getPath(get, 'summary_meta_data.context.uuid', null),
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

export default CollectionDetailAdditional
module.exports = CollectionDetailAdditional
