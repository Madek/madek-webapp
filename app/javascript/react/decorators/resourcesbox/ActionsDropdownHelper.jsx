/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import f from 'active-lodash'
import SelectionScope from '../../../lib/selection-scope.js'

const showActionsConfig = function (parameters) {
  const {
    withActions,
    selection,
    saveable,
    draftsView,
    isClient,
    collectionData,
    featureToggles,
    isClipboard
  } = parameters
  const showActions = !withActions
    ? {}
    : {
        addToClipboard: !isClipboard && selection && !draftsView ? true : undefined,
        removeFromClipboard: isClipboard && selection && !draftsView ? true : undefined,
        addToSet: selection && !draftsView ? true : undefined,
        edit: selection ? true : undefined,
        editSets: selection ? true : undefined,
        deleteResources: selection ? true : undefined,
        managePermissions: !draftsView && selection ? true : undefined,
        managePermissionsSets: !draftsView && selection ? true : undefined,
        save: isClient && saveable ? true : undefined,
        removeFromSet:
          !isClipboard && selection && f.present(collectionData) && !draftsView ? true : undefined,
        transferResponsibility: !draftsView && selection ? true : undefined,
        transferResponsibilitySets: !draftsView && selection ? true : undefined,
        quickEdit: !!featureToggles.beta_test_quick_edit
      }
  return showActions
}

const highlightingRules = function (item, isSelected) {
  const highlighting_rules = [
    {
      hoverMenuId: 'media_entries_edit_all',
      rule() {
        return item.type !== 'MediaEntry'
      }
    },
    {
      hoverMenuId: 'media_entries_edit',
      rule() {
        return (
          !SelectionScope.batchMetaDataResource(item) || item.type !== 'MediaEntry' || !isSelected
        )
      }
    },
    {
      hoverMenuId: 'media_entries_edit_title',
      rule() {
        return (
          !SelectionScope.batchMetaDataResource(item) || item.type !== 'MediaEntry' || !isSelected
        )
      }
    },
    {
      hoverMenuId: 'collections_edit_all',
      rule() {
        return item.type !== 'Collection'
      }
    },
    {
      hoverMenuId: 'collections_edit',
      rule() {
        return (
          !SelectionScope.batchMetaDataResource(item) || item.type !== 'Collection' || !isSelected
        )
      }
    },
    {
      hoverMenuId: 'resources_destroy',
      rule() {
        return (
          !SelectionScope.batchDestroyResource(item) ||
          (item.type !== 'MediaEntry' && item.type !== 'Collection') ||
          !isSelected
        )
      }
    },
    {
      hoverMenuId: 'media_entries_permissions',
      rule() {
        return (
          !SelectionScope.batchPermissionResource(item) || item.type !== 'MediaEntry' || !isSelected
        )
      }
    },
    {
      hoverMenuId: 'collections_permissions',
      rule() {
        return (
          !SelectionScope.batchPermissionResource(item) || item.type !== 'Collection' || !isSelected
        )
      }
    },
    {
      hoverMenuId: 'add_all_to_clipboard',
      rule() {
        return (item.type !== 'MediaEntry' && item.type !== 'Collection') || item.on_clipboard
      }
    },
    {
      hoverMenuId: 'add_selected_to_clipboard',
      rule() {
        return (
          (item.type !== 'MediaEntry' && item.type !== 'Collection') ||
          !isSelected ||
          item.on_clipboard
        )
      }
    },
    {
      hoverMenuId: 'remove_all_from_clipboard',
      rule() {
        return (item.type !== 'MediaEntry' && item.type !== 'Collection') || !item.on_clipboard
      }
    },
    {
      hoverMenuId: 'remove_from_clipboard',
      rule() {
        return (
          (item.type !== 'MediaEntry' && item.type !== 'Collection') ||
          !isSelected ||
          !item.on_clipboard
        )
      }
    },
    {
      hoverMenuId: 'add_to_set',
      rule() {
        return (item.type !== 'MediaEntry' && item.type !== 'Collection') || !isSelected
      }
    },
    {
      hoverMenuId: 'remove_from_set',
      rule() {
        return (item.type !== 'MediaEntry' && item.type !== 'Collection') || !isSelected
      }
    },
    {
      hoverMenuId: 'media_entries_transfer_responsibility',
      rule() {
        return (
          !SelectionScope.batchTransferResponsibilityResource(item) ||
          item.type !== 'MediaEntry' ||
          !isSelected
        )
      }
    },
    {
      hoverMenuId: 'collections_transfer_responsibility',
      rule() {
        return (
          !SelectionScope.batchTransferResponsibilityResource(item) ||
          item.type !== 'Collection' ||
          !isSelected
        )
      }
    }
  ]

  return highlighting_rules
}

const isResourceNotInScope = function (item, isSelected, hoverMenuId) {
  const found_rules = f.filter(highlightingRules(item, isSelected), { hoverMenuId })
  return !f.isEmpty(found_rules) && f.first(found_rules).rule() === true
}

const ActionsDropdownHelper = {
  isResourceNotInScope,
  showActionsConfig
}

module.exports = ActionsDropdownHelper
