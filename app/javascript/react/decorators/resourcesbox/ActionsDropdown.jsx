/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import l from 'lodash'
import { t } from '../../lib/ui.js'
import SelectionScope from '../../../lib/selection-scope.js'
import { Icon, Dropdown } from '../../ui-components/index.js'
import ActionsDropdownHelper from './ActionsDropdownHelper.jsx'

export default createReactClass({
  displayName: 'ActionsDropdown',

  shouldComponentUpdate(nextProps, nextState) {
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  },

  render() {
    const { parameters, callbacks } = this.props

    const showActions = ActionsDropdownHelper.showActionsConfig(parameters)

    if (!f.any(f.values(showActions))) {
      return null
    }

    const {
      totalCount,
      selection,
      collectionData,
      isClipboard,
      content_type,
      showAddSetButton
    } = parameters

    const nofSelected = selection ? selection.length : 0

    const createHoverActionItem = (enableEntryByOnClick, hoverId, count, icon, text) => (
      <Dropdown.MenuItem
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
      </Dropdown.MenuItem>
    )

    return (
      <Dropdown
        mods="stick-right mlm"
        testId="resources_box_dropdown"
        toggle={t('resources_box_batch_actions_menu_title')}
        toggleProps={{ className: 'button' }}>
        <Dropdown.Menu className="ui-drop-menu">
          {showAddSetButton && (
            <Dropdown.MenuItem onClick={callbacks.onShowCreateCollectionModal}>
              <Icon
                i="plus"
                mods="ui-drop-icon"
                style={{ display: 'inline-block', minWidth: '20px', marginLeft: '5px' }}
              />
              <span style={{ display: 'inline', marginLeft: '5px' }}>
                {t('resource_action_collection_create')}
              </span>
            </Dropdown.MenuItem>
          )}
          {showAddSetButton && <Dropdown.MenuItem className="separator" />}

          {showActions.addToSet &&
            createHoverActionItem(
              nofSelected > 0 ? f.curry(callbacks.onBatchAddToSet)(selection) : undefined,
              'add_to_set',
              nofSelected,
              'move',
              t('resources_box_batch_actions_addtoset')
            )}

          {showActions.removeFromSet &&
            createHoverActionItem(
              nofSelected > 0 ? f.curry(callbacks.onBatchRemoveFromSet)(selection) : undefined,
              'remove_from_set',
              nofSelected,
              'close',
              t('resources_box_batch_actions_removefromset')
            )}

          {(() => {
            if (showActions.edit) {
              if (
                (collectionData || isClipboard) &&
                nofSelected === 0 &&
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
            // Edit media entry titles
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
                nofSelected === 0 &&
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
            <Dropdown.MenuItem onClick={this.props.callbacks.onQuickBatch}>
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
            </Dropdown.MenuItem>
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
            ? nofSelected === 0
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
                  nofSelected > 0
                    ? f.curry(callbacks.onBatchAddSelectedToClipboard)(selection)
                    : undefined,
                  'add_selected_to_clipboard',
                  nofSelected,
                  'clipboard',
                  t('resources_box_batch_actions_addselectedtoclipboard')
                )
            : undefined}

          {showActions.removeFromClipboard
            ? nofSelected === 0
              ? createHoverActionItem(
                  totalCount > 0 ? callbacks.onBatchRemoveAllFromClipboard : undefined,
                  'remove_all_from_clipboard',
                  undefined,
                  'close',
                  t('resources_box_batch_actions_clear_clipboard')
                )
              : createHoverActionItem(
                  nofSelected > 0
                    ? f.curry(callbacks.onBatchRemoveFromClipboard)(selection)
                    : undefined,
                  'remove_from_clipboard',
                  nofSelected,
                  'close',
                  t('resources_box_batch_actions_removefromclipboard')
                )
            : undefined}
        </Dropdown.Menu>
      </Dropdown>
    )
  }
})
