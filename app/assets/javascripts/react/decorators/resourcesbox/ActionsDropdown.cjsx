React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t('de')
SelectionScope = require('../../../lib/selection-scope.coffee')
{ Icon, Dropdown } = require('../../ui-components/index.coffee')
MenuItem = Dropdown.MenuItem

createActionsDropdown = (withActions, selection, saveable, disablePermissionsEdit, isClient, collectionData, config, callbacks) ->

  showActions = if not withActions then {} else {
    addToSet: true if selection
    edit: true if selection
    editSets: true if selection
    managePermissions: true if !disablePermissionsEdit && selection
    managePermissionsSets: true if !disablePermissionsEdit && selection
    save: true if isClient and saveable
    removeFromSet: true if selection && f.present(collectionData)
  }

  createHoverActionItem = (onClick, hoverId, count, icon, textKey) ->
    <MenuItem onClick={onClick}
      onMouseEnter={f.curry(callbacks.onHoverMenu)(hoverId)} onMouseLeave={f.curry(callbacks.onHoverMenu)(null)}>
      <Icon i={icon} mods="ui-drop-icon"
      /> <span className="ui-count">
        {count}
      </span> {t(textKey)}
    </MenuItem>


  actionsDropdown = if f.any(f.values(showActions))
    <Dropdown mods='stick-right mlm' testId='resources_box_dropdown'
      toggle={'Aktionen'} toggleProps={{className: 'button'}}>

      <Dropdown.Menu className='ui-drop-menu'>

        {if showActions.addToSet
          createHoverActionItem(
            if !selection.empty() then callbacks.onBatchAddToSet,
            'add_to_set',
            selection.length(),
            'move',
            'resources_box_batch_actions_addtoset')}

        {if showActions.removeFromSet
          createHoverActionItem(
            if !selection.empty() then callbacks.onBatchRemoveFromSet,
            'remove_from_set',
            selection.length(),
            'close',
            'resources_box_batch_actions_removefromset')}

        {if showActions.edit
          batchEditables = SelectionScope.batchMetaDataResources(selection, ['MediaEntry']) if selection
          createHoverActionItem(
            if f.present(batchEditables) then f.curry(callbacks.onBatchEdit)(batchEditables),
            'media_entries_edit',
            batchEditables.length,
            'pen',
            'resources_box_batch_actions_edit')}

        {if showActions.editSets
          batchSetEditables = SelectionScope.batchMetaDataResources(selection, ['Collection']) if selection
          createHoverActionItem(
            if f.present(batchSetEditables) then f.curry(callbacks.onBatchEditSets)(batchSetEditables),
            'collections_edit',
            batchSetEditables.length,
            'pen',
            'resources_box_batch_actions_edit_sets')}

        {if showActions.managePermissions
          batchPermissionEditables = SelectionScope.batchPermissionResources(selection, ['MediaEntry']) if selection
          createHoverActionItem(
            if f.present(batchPermissionEditables) then f.curry(callbacks.onBatchPermissionsEdit)(batchPermissionEditables),
            'media_entries_permissions',
            batchPermissionEditables.length,
            'lock',
            'resources_box_batch_actions_managepermissions')}

        {if showActions.managePermissionsSets and false
          batchPermissionSetsEditables = SelectionScope.batchPermissionResources(selection, ['Collection']) if selection
          createHoverActionItem(
            if f.present(batchPermissionSetsEditables) then f.curry(callbacks.onBatchPermissionsSetsEdit)(batchPermissionSetsEditables),
            'collections_permissions',
            batchPermissionSetsEditables.length,
            'lock',
            'resources_box_batch_actions_sets_managepermissions')}

        {if showActions.save
          <MenuItem className="separator"/>}
        {if showActions.save
          <MenuItem onClick={(if f.present(config.filter) then f.curry(callbacks.onCreateFilterSet)(config))}>
            <Icon i="filter" mods="ui-drop-icon"/> {t('resources_box_batch_actions_save')}
          </MenuItem>}

      </Dropdown.Menu>
    </Dropdown>

  actionsDropdown



highlightingRules = (item, isSelected) ->

  highlighting_rules = [
    {
      hoverMenuId: 'media_entries_edit'
      rule: () -> (!SelectionScope.batchMetaDataResource(item.serialize()) or
        item.type != 'MediaEntry' or not isSelected)
    }
    {
      hoverMenuId: 'collections_edit'
      rule: () -> (!SelectionScope.batchMetaDataResource(item.serialize()) or
        item.type != 'Collection' or not isSelected)
    }
    {
      hoverMenuId: 'media_entries_permissions'
      rule: () -> (!SelectionScope.batchPermissionResource(item.serialize()) or
        item.type != 'MediaEntry' or not isSelected)
    }
    {
      hoverMenuId: 'collections_permissions'
      rule: () -> (!SelectionScope.batchPermissionResource(item.serialize()) or
        item.type != 'Collection' or not isSelected)
    }
    {
      hoverMenuId: 'add_to_set'
      rule: () ->
        (!SelectionScope.batchPermissionResource(item.serialize()) or
          (item.type != 'MediaEntry' and item.type != 'Collection') or not isSelected)
    }
    {
      hoverMenuId: 'remove_from_set'
      rule: () -> (!SelectionScope.batchPermissionResource(item.serialize()) or
        (item.type != 'MediaEntry' and item.type != 'Collection') or not isSelected)
    }
  ]

  highlighting_rules


isResourceNotInScope = (item, isSelected, hoverMenuId) ->
  found_rules = f.filter(highlightingRules(item, isSelected), {hoverMenuId: hoverMenuId})
  not f.isEmpty(found_rules) and f.first(found_rules).rule() == true



ActionsDropdown = {
  createActionsDropdown: createActionsDropdown
  isResourceNotInScope: isResourceNotInScope
}


module.exports = ActionsDropdown
