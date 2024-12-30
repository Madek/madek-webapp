React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t
SelectionScope = require('../../../lib/selection-scope.coffee')
{ Icon, Dropdown } = require('../../ui-components/index.coffee')
MenuItem = Dropdown.MenuItem



showActionsConfig = (parameters) ->
  {totalCount, withActions, selection, saveable, draftsView, isClient, collectionData, config, featureToggles, isClipboard, content_type} = parameters
  showActions = if not withActions then {} else {
    addToClipboard: true if !isClipboard && selection && !draftsView
    removeFromClipboard: true if isClipboard && selection && !draftsView
    addToSet: true if selection && !draftsView
    edit: true if selection
    editSets: true if selection
    deleteResources: true if selection
    managePermissions: true if !draftsView && selection
    managePermissionsSets: true if !draftsView && selection
    save: true if isClient and saveable
    removeFromSet: true if !isClipboard && selection && f.present(collectionData) && !draftsView
    transferResponsibility: true if !draftsView && selection
    transferResponsibilitySets: true if !draftsView && selection
    quickEdit: !!featureToggles.beta_test_quick_edit
  }
  showActions


highlightingRules = (item, isSelected) ->

  highlighting_rules = [
    {
      hoverMenuId: 'media_entries_edit_all'
      rule: () ->
        (item.type != 'MediaEntry')
    }
    {
      hoverMenuId: 'media_entries_edit'
      rule: () -> (!SelectionScope.batchMetaDataResource(item) or
        item.type != 'MediaEntry' or (not isSelected))
    }
    {
      hoverMenuId: 'collections_edit_all'
      rule: () ->
        (item.type != 'Collection')
    }
    {
      hoverMenuId: 'collections_edit'
      rule: () -> (!SelectionScope.batchMetaDataResource(item) or
        item.type != 'Collection' or (not isSelected))
    }
    {
      hoverMenuId: 'resources_destroy'
      rule: () -> (!SelectionScope.batchDestroyResource(item) or
        (item.type != 'MediaEntry' and item.type != 'Collection') or not isSelected)
    }
    {
      hoverMenuId: 'media_entries_permissions'
      rule: () -> (!SelectionScope.batchPermissionResource(item) or
        item.type != 'MediaEntry' or (not isSelected))
    }
    {
      hoverMenuId: 'collections_permissions'
      rule: () -> (!SelectionScope.batchPermissionResource(item) or
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
      rule: () -> (!SelectionScope.batchTransferResponsibilityResource(item) or
        (item.type != 'MediaEntry') or (not isSelected))
    }
    {
      hoverMenuId: 'collections_transfer_responsibility'
      rule: () -> (!SelectionScope.batchTransferResponsibilityResource(item) or
        (item.type != 'Collection') or (not isSelected))
    }
  ]

  highlighting_rules


isResourceNotInScope = (item, isSelected, hoverMenuId) ->
  found_rules = f.filter(highlightingRules(item, isSelected), {hoverMenuId: hoverMenuId})
  not f.isEmpty(found_rules) and f.first(found_rules).rule() == true



ActionsDropdownHelper = {
  isResourceNotInScope: isResourceNotInScope
  showActionsConfig: showActionsConfig
}


module.exports = ActionsDropdownHelper
