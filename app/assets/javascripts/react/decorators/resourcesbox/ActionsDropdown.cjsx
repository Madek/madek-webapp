React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t('de')
SelectionScope = require('../../../lib/selection-scope.coffee')
{ Icon, Dropdown } = require('../../ui-components/index.coffee')
MenuItem = Dropdown.MenuItem

createActionsDropdown = (totalCount, withActions, selection, saveable, disablePermissionsEdit, isClient, collectionData, config, isClipboard, callbacks) ->
  showActions = if not withActions then {} else {
    addToClipboard: true if !isClipboard
    removeFromClipboard: true if isClipboard
    addToSet: true if selection
    edit: true if selection
    editSets: true if selection
    managePermissions: true if !disablePermissionsEdit && selection
    managePermissionsSets: true if !disablePermissionsEdit && selection
    save: true if isClient and saveable
    removeFromSet: true if selection && f.present(collectionData)
    transferResponsibility: true if !disablePermissionsEdit && selection
    transferResponsibilitySets: true if !disablePermissionsEdit && selection
  }

  return unless f.any(f.values(showActions))

  createHoverActionItem = (enableEntryByOnClick, hoverId, count, icon, text) ->
    <MenuItem onClick={enableEntryByOnClick}
      onMouseEnter={f.curry(callbacks.onHoverMenu)(hoverId)} onMouseLeave={f.curry(callbacks.onHoverMenu)(null)}>
      <Icon i={icon} mods='ui-drop-icon' style={{position: 'static', display: 'inline-block', minWidth: '20px', marginLeft: '5px'}} />
      {
        if count != undefined
          <span className='ui-count' style={{position: 'static', display: 'inline-block', minWidth: '10px', marginLeft: '5px', paddingLeft: '0px', textAlign: 'left'}}>
            {count}
          </span>
      }
      <span style={{display: 'inline', marginLeft: '5px'}}>
        {text}
      </span>
    </MenuItem>


  actionsDropdown = if f.any(f.values(showActions))
    <Dropdown mods='stick-right mlm' testId='resources_box_dropdown'
      toggle={'Aktionen'} toggleProps={{className: 'button'}}>

      <Dropdown.Menu className='ui-drop-menu'>

        {if showActions.addToSet
          createHoverActionItem(
            if !selection.empty() then f.curry(callbacks.onBatchAddToSet)(selection.selection),
            'add_to_set',
            selection.length(),
            'move',
            t('resources_box_batch_actions_addtoset'))}

        {if showActions.removeFromSet
          createHoverActionItem(
            if !selection.empty() then f.curry(callbacks.onBatchRemoveFromSet)(selection.selection),
            'remove_from_set',
            selection.length(),
            'close',
            t('resources_box_batch_actions_removefromset'))}

        {if showActions.edit
          # TODO if selection most likely not needed, should be already included in the if condition.
          batchEditables = SelectionScope.batchMetaDataResources(selection, ['MediaEntry']) if selection
          createHoverActionItem(
            if f.present(batchEditables) then f.curry(callbacks.onBatchEdit)(batchEditables),
            'media_entries_edit',
            batchEditables.length,
            'pen',
            t('resources_box_batch_actions_edit'))}

        {if showActions.editSets
          # TODO if selection most likely not needed, should be already included in the if condition.
          batchSetEditables = SelectionScope.batchMetaDataResources(selection, ['Collection']) if selection
          createHoverActionItem(
            if f.present(batchSetEditables) then f.curry(callbacks.onBatchEditSets)(batchSetEditables),
            'collections_edit',
            batchSetEditables.length,
            'pen',
            t('resources_box_batch_actions_edit_sets'))}

        {if showActions.managePermissions
          # TODO if selection most likely not needed, should be already included in the if condition.
          batchPermissionEditables = SelectionScope.batchPermissionResources(selection, ['MediaEntry']) if selection
          createHoverActionItem(
            if f.present(batchPermissionEditables) then f.curry(callbacks.onBatchPermissionsEdit)(batchPermissionEditables),
            'media_entries_permissions',
            batchPermissionEditables.length,
            'lock',
            t('resources_box_batch_actions_managepermissions'))}

        {if showActions.managePermissionsSets
          # TODO if selection most likely not needed, should be already included in the if condition.
          batchPermissionSetsEditables = SelectionScope.batchPermissionResources(selection, ['Collection']) if selection
          createHoverActionItem(
            if f.present(batchPermissionSetsEditables) then f.curry(callbacks.onBatchPermissionsSetsEdit)(batchPermissionSetsEditables),
            'collections_permissions',
            batchPermissionSetsEditables.length,
            'lock',
            t('resources_box_batch_actions_sets_managepermissions'))}

        {if showActions.transferResponsibility
          # TODO if selection most likely not needed, should be already included in the if condition.
          batchTransferResponsibilityEditables = SelectionScope.batchTransferResponsibilityResources(selection, ['MediaEntry']) if selection
          createHoverActionItem(
            if f.present(batchTransferResponsibilityEditables) then f.curry(callbacks.onBatchTransferResponsibilityEdit)(batchTransferResponsibilityEditables),
            'media_entries_transfer_responsibility',
            batchTransferResponsibilityEditables.length,
            'user',
            t('resources_box_batch_actions_transfer_responsibility_entries'))}

        {if showActions.transferResponsibilitySets
          # TODO if selection most likely not needed, should be already included in the if condition.
          batchTransferResponsibilitySetsEditables = SelectionScope.batchTransferResponsibilityResources(selection, ['Collection']) if selection
          createHoverActionItem(
            if f.present(batchTransferResponsibilitySetsEditables) then f.curry(callbacks.onBatchTransferResponsibilitySetsEdit)(batchTransferResponsibilitySetsEditables),
            'collections_transfer_responsibility',
            batchTransferResponsibilitySetsEditables.length,
            'user',
            t('resources_box_batch_actions_transfer_responsibility_sets'))}


        {if showActions.addToClipboard
          if (not selection) || selection.empty()
            createHoverActionItem(
              if totalCount > 0 then callbacks.onBatchAddAllToClipboard,
              'add_all_to_clipboard',
              undefined,
              'move',
              t('resources_box_batch_actions_addalltoclipboard'))
          else
            createHoverActionItem(
              if !selection.empty() then f.curry(callbacks.onBatchAddSelectedToClipboard)(selection.selection),
              'add_selected_to_clipboard',
              selection.length(),
              'move',
              t('resources_box_batch_actions_addselectedtoclipboard'))}

        {if showActions.removeFromClipboard
          if (not selection) || selection.empty()
            createHoverActionItem(
              if totalCount > 0 then callbacks.onBatchRemoveAllFromClipboard,
              'remove_all_from_clipboard',
              undefined,
              'move',
              t('resources_box_batch_actions_removeallfromclipboard'))
          else
            createHoverActionItem(
              if !selection.empty() then f.curry(callbacks.onBatchRemoveFromClipboard)(selection.selection),
              'remove_from_clipboard',
              selection.length(),
              'close',
              t('resources_box_batch_actions_removefromclipboard'))}



        {
          # {if showActions.save
          #   <MenuItem className="separator"/>}
          # {if showActions.save
          #   <MenuItem onClick={(if f.present(config.filter) then f.curry(callbacks.onCreateFilterSet)(config))}>
          #     <Icon i="filter" mods="ui-drop-icon"/> {t('resources_box_batch_actions_save')}
          #   </MenuItem>}
          null
        }

      </Dropdown.Menu>
    </Dropdown>

  actionsDropdown



highlightingRules = (item, isSelected) ->

  highlighting_rules = [
    {
      hoverMenuId: 'media_entries_edit'
      rule: () -> (!SelectionScope.batchMetaDataResource(item.serialize()) or
        item.type != 'MediaEntry' or (not isSelected))
    }
    {
      hoverMenuId: 'collections_edit'
      rule: () -> (!SelectionScope.batchMetaDataResource(item.serialize()) or
        item.type != 'Collection' or (not isSelected))
    }
    {
      hoverMenuId: 'media_entries_permissions'
      rule: () -> (!SelectionScope.batchPermissionResource(item.serialize()) or
        item.type != 'MediaEntry' or (not isSelected))
    }
    {
      hoverMenuId: 'collections_permissions'
      rule: () -> (!SelectionScope.batchPermissionResource(item.serialize()) or
        item.type != 'Collection' or (not isSelected))
    }
    {
      hoverMenuId: 'add_all_to_clipboard'
      rule: () ->
        ((item.type != 'MediaEntry' and item.type != 'Collection') or item.on_clipboard)
    }
    {
      hoverMenuId: 'add_selected_to_clipboard'
      rule: () ->
        ((item.type != 'MediaEntry' and item.type != 'Collection') or (not isSelected) or item.on_clipboard)
    }
    {
      hoverMenuId: 'remove_all_from_clipboard'
      rule: () ->
        ((item.type != 'MediaEntry' and item.type != 'Collection') or (not item.on_clipboard))
    }
    {
      hoverMenuId: 'remove_from_clipboard'
      rule: () ->
        ((item.type != 'MediaEntry' and item.type != 'Collection') or (not isSelected) or (not item.on_clipboard))
    }
    {
      hoverMenuId: 'add_to_set'
      rule: () ->
        ((item.type != 'MediaEntry' and item.type != 'Collection') or (not isSelected))
    }
    {
      hoverMenuId: 'remove_from_set'
      rule: () -> ((item.type != 'MediaEntry' and item.type != 'Collection') or (not isSelected))
    }
    {
      hoverMenuId: 'media_entries_transfer_responsibility'
      rule: () -> (!SelectionScope.batchTransferResponsibilityResource(item.serialize()) or
        (item.type != 'MediaEntry') or (not isSelected))
    }
    {
      hoverMenuId: 'collections_transfer_responsibility'
      rule: () -> (!SelectionScope.batchTransferResponsibilityResource(item.serialize()) or
        (item.type != 'Collection') or (not isSelected))
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
