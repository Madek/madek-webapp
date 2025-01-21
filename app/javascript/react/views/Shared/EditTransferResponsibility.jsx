/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import t from '../../../lib/i18n-translate.js'
import RailsForm from '../../lib/forms/rails-form.jsx'
import railsFormPut from '../../../lib/form-put-with-errors.js'
import AutoComplete from '../../lib/autocomplete-wrapper.jsx'
import interpolateSplit from '../../../lib/interpolate-split.js'

module.exports = createReactClass({
  displayName: 'Shared.EditTransferResponsibility',

  getInitialState() {
    return {
      saving: false,
      permissionLevel: 4,
      selectedEntity: null
    }
  },

  // NOTE: just to be save, block *implicit* form submits
  // (should normally not be triggered when button[type=button] is used.)
  _onImplicitSumbit(event) {
    return event.preventDefault()
  },

  _onExplicitSubmit(event) {
    event.preventDefault()
    this._submit(event)
    return false
  },

  _submit() {
    this.setState({ saving: true })
    return railsFormPut.byForm(this.refs.form, result => {
      if (result.result === 'error') {
        window.scrollTo(0, 0)
        return this.setState({ saving: false, errorMessage: result.message })
      } else {
        if (!this.props.batch) {
          if (!result.data.viewable) {
            return (location.href = this.props.singleResourceFallbackUrl)
          } else {
            return (location.href = this.props.singleResourcePermissionsUrl)
          }
        } else {
          return location.reload()
        }
      }
    })
  },

  handleEntitySelect(entity) {
    return this.setState({ selectedEntity: entity })
  },

  handleEntityClear() {
    return this.setState({ selectedEntity: null })
  },

  _onToggleCheckbox(level) {
    if (level > this.state.permissionLevel) {
      return this.setState({ permissionLevel: level })
    } else {
      return this.setState({ permissionLevel: level - 1 })
    }
  },

  _displayBlockIf(bool) {
    if (bool) {
      return { display: 'block' }
    } else {
      return { display: 'none' }
    }
  },

  _translateForNResources(resourceType, n) {
    if (resourceType === 'Collection') {
      if (n === 1) {
        return interpolateSplit(t('transfer_responsibility_for_1_collection')).join('')
      } else {
        return interpolateSplit(t('transfer_responsibility_for_n_collections'), {
          nofResources: n
        }).join('')
      }
    } else {
      if (n === 1) {
        return interpolateSplit(t('transfer_responsibility_for_1_media_entry')).join('')
      } else {
        return interpolateSplit(t('transfer_responsibility_for_n_media_entries'), {
          nofResources: n
        }).join('')
      }
    }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const {
      authToken,
      currentUser,
      batch,
      resourceType,
      singleResourceActionUrl,
      batchResourceIds,
      batchActionUrls,
      responsible,
      batchResponsibles,
      onClose
    } = param
    const actionUrl = (() => {
      if (!batch) {
        return singleResourceActionUrl
      } else {
        const batchActionUrl = batchActionUrls[resourceType]
        if (!batchActionUrl) {
          throw new Error(`Action url not available for batch type: ${resourceType}`)
        }
        return batchActionUrl
      }
    })()

    const responsibles = batch ? batchResponsibles : [responsible]

    return (
      <div className="bright ui-container pal rounded">
        <RailsForm
          ref="form"
          name="transfer_responsibility"
          action={actionUrl}
          onSubmit={this._onImplicitSumbit}
          method="put"
          authToken={authToken}>
          {batch
            ? f.map(batchResourceIds, resource_id => (
                <input key={resource_id} type="hidden" name="id[]" value={resource_id} />
              ))
            : undefined}
          {this.state.errorMessage ? (
            <div className="ui-alerts" style={{ marginBottom: '10px' }}>
              <div className="error ui-alert">{this.state.errorMessage}</div>
            </div>
          ) : (
            undefined
          )}
          {batch ? (
            <h2 className="title-l ui-info-box-title mbm">
              {interpolateSplit(t('transfer_responsibility_title_batch'), {
                forNResources: this._translateForNResources(resourceType, batchResourceIds.length)
              })}
            </h2>
          ) : (
            <h2 className="title-l ui-info-box-title mbm">
              {t('transfer_responsibility_title_single')}
            </h2>
          )}
          <div className="title-m ">{t('transfer_responsibility_currently_responsible')}</div>
          <div className="mbm">
            {(() => {
              const result = []

              for (var idx in responsibles) {
                var r = responsibles[idx]
                result.push(
                  <div key={idx}>
                    {r.name}
                    {responsibles.length > 1
                      ? ` ${this._translateForNResources(resourceType, r.nofResources)}`
                      : undefined}
                  </div>
                )
              }

              return result
            })()}
          </div>
          <div className="title-m">{t('transfer_responsibility_to')}</div>
          <div className="ui-rights-user" style={this._displayBlockIf(this.state.selectedEntity)}>
            <a
              onClick={this.handleEntityClear}
              className="button small ui-rights-remove icon-close small"
              title={t('permissions_table_remove_subject_btn')}
            />
            <input
              type="hidden"
              name="transfer_responsibility[entity]"
              value={this.state.selectedEntity ? this.state.selectedEntity.uuid : ''}
            />
            <input
              type="hidden"
              name="transfer_responsibility[type]"
              value={this.state.selectedEntity ? this.state.selectedEntity.type : ''}
            />
            <span className="text">
              {this.state.selectedEntity ? this.state.selectedEntity.name : undefined}
            </span>
          </div>
          <div style={this._displayBlockIf(!this.state.selectedEntity)}>
            <AutoComplete
              className="block"
              name="transfer_responsibility[unused_look_at_the_hidden_user]"
              resourceType={['Delegations', 'Users']}
              onSelect={this.handleEntitySelect}
              searchParams={{ search_also_in_person: true }}
              positionRelative={true}
            />
          </div>
          <div>
            <h2 className="title-m ui-info-box-title mtm mbs">
              {responsibles.length === 1
                ? responsibles[0].uuid === currentUser.uuid
                  ? interpolateSplit(t('transfer_responsibility_you_will_receive'), {
                      name: responsibles[0].name
                    }).join('')
                  : interpolateSplit(t('transfer_responsibility_single_will_receive'), {
                      name: responsibles[0].name
                    }).join('')
                : t('transfer_responsibility_multiple_will_receive')}
            </h2>
            <table className="ui-rights-group">
              <tbody>
                <tr>
                  <td style={{ textAlign: 'center', border: '0px' }}>
                    {t('permission_name_get_metadata_and_previews')}
                  </td>
                  {resourceType === 'MediaEntry' ? (
                    <td style={{ textAlign: 'center', border: '0px' }}>
                      {t('permission_name_get_full_size')}
                    </td>
                  ) : (
                    undefined
                  )}
                  <td style={{ textAlign: 'center', border: '0px' }}>
                    {resourceType === 'Collection'
                      ? t('permission_name_edit_metadata_and_relations')
                      : t('permission_name_edit_metadata')}
                  </td>
                  <td style={{ textAlign: 'center', border: '0px' }}>
                    {t('permission_name_edit_permissions')}
                  </td>
                </tr>
                <tr>
                  <td style={{ textAlign: 'center', border: '0px' }}>
                    <input
                      type="checkbox"
                      name="transfer_responsibility[permissions][view]"
                      checked={this.state.permissionLevel >= 1}
                      onChange={event => this._onToggleCheckbox(1, event)}
                    />
                  </td>
                  {resourceType === 'MediaEntry' ? (
                    <td style={{ textAlign: 'center', border: '0px' }}>
                      <input
                        type="checkbox"
                        name="transfer_responsibility[permissions][download]"
                        checked={this.state.permissionLevel >= 2}
                        onChange={event => this._onToggleCheckbox(2, event)}
                      />
                    </td>
                  ) : (
                    undefined
                  )}
                  <td style={{ textAlign: 'center', border: '0px' }}>
                    <input
                      type="checkbox"
                      name="transfer_responsibility[permissions][edit]"
                      checked={this.state.permissionLevel >= 3}
                      onChange={event => this._onToggleCheckbox(3, event)}
                    />
                  </td>
                  <td style={{ textAlign: 'center', border: '0px' }}>
                    <input
                      type="checkbox"
                      name="transfer_responsibility[permissions][manage]"
                      checked={this.state.permissionLevel >= 4}
                      onChange={event => this._onToggleCheckbox(4, event)}
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div className="ui-actions phl pbl mtl">
            <a className="link weak" onClick={onClose}>
              {' '}
              {t('transfer_responsibility_cancel')}{' '}
            </a>
            <button
              disabled={!this.state.selectedEntity || this.state.saving}
              className="primary-button large"
              onClick={this._onExplicitSubmit}
              type="button">
              {t('transfer_responsibility_submit')}
            </button>
          </div>
        </RailsForm>
      </div>
    )
  }
})
