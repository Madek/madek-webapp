/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const ui = require('../../lib/ui.js')
const { t } = ui
const SelectionScope = require('../../../lib/selection-scope.js')
const { Icon, Dropdown } = require('../../ui-components/index.js')
const { MenuItem } = Dropdown
const ActionsDropdownHelper = require('./ActionsDropdownHelper.jsx')

module.exports = React.createClass({
  displayName: 'ActionsDropdown',

  shouldComponentUpdate(nextProps, nextState) {
    const l = require('lodash')
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  },

  render() {
    const { parameters } = this.props
    const { callbacks } = this.props

    const showActions = ActionsDropdownHelper.showActionsConfig(parameters)

    if (!f.any(f.values(showActions))) {
      return null
    }

    const {
      totalCount,
      withActions,
      selection,
      saveable,
      draftsView,
      isClient,
      collectionData,
      config,
      isClipboard,
      content_type,
      showAddSetButton
    } = parameters

    const createHoverActionItem = (enableEntryByOnClick, hoverId, count, icon, text) => (
      <MenuItem
        onClick={enableEntryByOnClick}
        onMouseEnter={f.curry(callbacks.onHoverMenu)(hoverId)}
        onMouseLeave={f.curry(callbacks.onHoverMenu)(null)}>
        <Icon
          i={icon}
          mods="ui-drop-icon"
          style={{
            position: 'static',
            display: 'inline-block',
            minWidth: '20px',
            marginLeft: '5px'
          }}
        />
        {count !== undefined ? (
          <span
            className="ui-count"
            style={{
              position: 'static',
              display: 'inline-block',
              minWidth: '10px',
              marginLeft: '5px',
              paddingLeft: '0px',
              textAlign: 'left'
            }}>
            {count}
          </span>
        ) : (
          undefined
        )}
        <span style={{ display: 'inline', marginLeft: '5px' }}>{text}</span>
      </MenuItem>
    )

    const actionsDropdown = f.any(f.values(showActions)) ? (
      <Dropdown
        mods="stick-right mlm"
        testId="resources_box_dropdown"
        toggle={t('resources_box_batch_actions_menu_title')}
        toggleProps={{ className: 'button' }}>
        <Dropdown.Menu className="ui-drop-menu">
          {showAddSetButton && (
            <MenuItem onClick={callbacks.onShowCreateCollectionModal}>
              <Icon
                i="plus"
                mods="ui-drop-icon"
                style={{ display: 'inline-block', minWidth: '20px', marginLeft: '5px' }}
              />
              <span style={{ display: 'inline', marginLeft: '5px' }}>
                {t('resource_action_collection_create')}
              </span>
            </MenuItem>
          )}
          {showAddSetButton && <MenuItem className="separator" />}
          {showActions.addToSet
            ? createHoverActionItem(
                selection.length > 0 ? f.curry(callbacks.onBatchAddToSet)(selection) : undefined,
                'add_to_set',
                selection.length,
                'move',
                t('resources_box_batch_actions_addtoset')
              )
            : undefined}
          {showActions.removeFromSet
            ? createHoverActionItem(
                selection.length > 0
                  ? f.curry(callbacks.onBatchRemoveFromSet)(selection)
                  : undefined,
                'remove_from_set',
                selection.length,
                'close',
                t('resources_box_batch_actions_removefromset')
              )
            : undefined}
          {(() => {
            if (showActions.edit) {
              if (
                (collectionData || isClipboard) &&
                (!selection || selection.length === 0) &&
                (content_type === 'MediaEntry' || content_type === 'MediaResource')
              ) {
                return createHoverActionItem(
                  totalCount > 0 ? callbacks.onBatchEditAll : undefined,
                  'media_entries_edit_all',
                  undefined,
                  'pen',
                  t('resources_box_batch_actions_edit_all_media_entries')
                )
              } else {
                let batchEditables
                if (selection) {
                  batchEditables = SelectionScope.batchMetaDataResources(selection, ['MediaEntry'])
                }
                return createHoverActionItem(
                  f.present(batchEditables)
                    ? f.curry(callbacks.onBatchEdit)(batchEditables)
                    : undefined,
                  'media_entries_edit',
                  batchEditables.length,
                  'pen',
                  t('resources_box_batch_actions_edit')
                )
              }
            }
          })()}
          {(() => {
            // Titel von Medieneinträgen editieren
            if (showActions.edit) {
              const batchEditables = selection
                ? SelectionScope.batchMetaDataResources(selection, ['MediaEntry'])
                : undefined
              return createHoverActionItem(
                batchEditables && batchEditables.length > 0 && batchEditables.length <= 12
                  ? f.curry(callbacks.onBatchEditTitle)(batchEditables.map(entry => entry.uuid))
                  : undefined,
                'media_entries_edit_title',
                batchEditables.length,
                'pen',
                t('resources_box_batch_actions_edit_title') + ' (max. 12)'
              )
            }
          })()}
          {(() => {
            if (showActions.editSets) {
              if (
                (collectionData || isClipboard) &&
                (!selection || selection.length === 0) &&
                (content_type === 'Collection' || content_type === 'MediaResource')
              ) {
                return createHoverActionItem(
                  totalCount > 0 ? callbacks.onBatchEditAllSets : undefined,
                  'collections_edit_all',
                  undefined,
                  'pen',
                  t('resources_box_batch_actions_edit_all_collections')
                )
              } else {
                let batchSetEditables
                if (selection) {
                  batchSetEditables = SelectionScope.batchMetaDataResources(selection, [
                    'Collection'
                  ])
                }
                return createHoverActionItem(
                  f.present(batchSetEditables)
                    ? f.curry(callbacks.onBatchEditSets)(batchSetEditables)
                    : undefined,
                  'collections_edit',
                  batchSetEditables.length,
                  'pen',
                  t('resources_box_batch_actions_edit_sets')
                )
              }
            }
          })()}
          {showActions.quickEdit ? (
            <MenuItem onClick={this.props.callbacks.onQuickBatch}>
              <i
                className="fa fa-magic"
                style={{
                  position: 'static',
                  display: 'inline-block',
                  minWidth: '20px',
                  marginLeft: '5px'
                }}
              />
              <span style={{ display: 'inline', marginLeft: '5px' }}>
                <span style={{ color: '#9a9a9a' }}>
                  {t('resources_box_batch_actions_meta_data_batch_new')}
                </span>{' '}
                {t('resources_box_batch_actions_meta_data_batch')}
              </span>
            </MenuItem>
          ) : (
            undefined
          )}
          {(() => {
            if (showActions.deleteResources) {
              let batchDestroyables
              if (selection) {
                batchDestroyables = SelectionScope.batchDestroyResources(selection, [
                  'MediaEntry',
                  'Collection'
                ])
              }
              return createHoverActionItem(
                f.present(batchDestroyables)
                  ? f.curry(callbacks.onBatchDeleteResources)(batchDestroyables)
                  : undefined,
                'resources_destroy',
                batchDestroyables.length,
                'trash',
                t('resources_box_batch_actions_delete')
              )
            }
          })()}
          {(() => {
            if (showActions.managePermissions) {
              let batchPermissionEditables
              if (selection) {
                batchPermissionEditables = SelectionScope.batchPermissionResources(selection, [
                  'MediaEntry'
                ])
              }
              return createHoverActionItem(
                f.present(batchPermissionEditables)
                  ? f.curry(callbacks.onBatchPermissionsEdit)(batchPermissionEditables)
                  : undefined,
                'media_entries_permissions',
                batchPermissionEditables.length,
                'lock',
                t('resources_box_batch_actions_managepermissions')
              )
            }
          })()}
          {(() => {
            if (showActions.managePermissionsSets) {
              let batchPermissionSetsEditables
              if (selection) {
                batchPermissionSetsEditables = SelectionScope.batchPermissionResources(selection, [
                  'Collection'
                ])
              }
              return createHoverActionItem(
                f.present(batchPermissionSetsEditables)
                  ? f.curry(callbacks.onBatchPermissionsSetsEdit)(batchPermissionSetsEditables)
                  : undefined,
                'collections_permissions',
                batchPermissionSetsEditables.length,
                'lock',
                t('resources_box_batch_actions_sets_managepermissions')
              )
            }
          })()}
          {(() => {
            if (showActions.transferResponsibility) {
              let batchTransferResponsibilityEditables
              if (selection) {
                batchTransferResponsibilityEditables = SelectionScope.batchTransferResponsibilityResources(
                  selection,
                  ['MediaEntry']
                )
              }
              return createHoverActionItem(
                f.present(batchTransferResponsibilityEditables)
                  ? f.curry(callbacks.onBatchTransferResponsibilityEdit)(
                      batchTransferResponsibilityEditables
                    )
                  : undefined,
                'media_entries_transfer_responsibility',
                batchTransferResponsibilityEditables.length,
                'user',
                t('resources_box_batch_actions_transfer_responsibility_entries')
              )
            }
          })()}
          {(() => {
            if (showActions.transferResponsibilitySets) {
              let batchTransferResponsibilitySetsEditables
              if (selection) {
                batchTransferResponsibilitySetsEditables = SelectionScope.batchTransferResponsibilityResources(
                  selection,
                  ['Collection']
                )
              }
              return createHoverActionItem(
                f.present(batchTransferResponsibilitySetsEditables)
                  ? f.curry(callbacks.onBatchTransferResponsibilitySetsEdit)(
                      batchTransferResponsibilitySetsEditables
                    )
                  : undefined,
                'collections_transfer_responsibility',
                batchTransferResponsibilitySetsEditables.length,
                'user',
                t('resources_box_batch_actions_transfer_responsibility_sets')
              )
            }
          })()}
          {showActions.addToClipboard
            ? !selection || selection.length === 0
              ? createHoverActionItem(
                  totalCount > 0 ? callbacks.onBatchAddAllToClipboard : undefined,
                  'add_all_to_clipboard',
                  undefined,
                  'clipboard',
                  t('resources_box_batch_actions_addalltoclipboard_1') +
                    totalCount +
                    t('resources_box_batch_actions_addalltoclipboard_2')
                )
              : createHoverActionItem(
                  selection.length > 0
                    ? f.curry(callbacks.onBatchAddSelectedToClipboard)(selection)
                    : undefined,
                  'add_selected_to_clipboard',
                  selection.length,
                  'clipboard',
                  t('resources_box_batch_actions_addselectedtoclipboard')
                )
            : undefined}
          {showActions.removeFromClipboard
            ? !selection || selection.length === 0
              ? createHoverActionItem(
                  totalCount > 0 ? callbacks.onBatchRemoveAllFromClipboard : undefined,
                  'remove_all_from_clipboard',
                  undefined,
                  'close',
                  t('resources_box_batch_actions_clear_clipboard')
                )
              : createHoverActionItem(
                  selection.length > 0
                    ? f.curry(callbacks.onBatchRemoveFromClipboard)(selection)
                    : undefined,
                  'remove_from_clipboard',
                  selection.length,
                  'close',
                  t('resources_box_batch_actions_removefromclipboard')
                )
            : undefined}
        </Dropdown.Menu>
      </Dropdown>
    ) : (
      undefined
    )

    return actionsDropdown
  }
})
