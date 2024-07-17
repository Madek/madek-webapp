React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/i18n-translate.js')
classnames = require('classnames')
xhr = require('xhr')
getRailsCSRFToken = require('../../../lib/rails-csrf-token.coffee')
setUrlParams = require('../../../lib/set-params-for-url.coffee')
RailsForm = require('../../lib/forms/rails-form.cjsx')
railsFormPut = require('../../../lib/form-put-with-errors.coffee')
AutoComplete = require('../../lib/autocomplete-wrapper.cjsx')
interpolateSplit = require('../../../lib/interpolate-split.js').default

module.exports = React.createClass
  displayName: 'Shared.EditTransferResponsibility'

  getInitialState: () ->
    {
      saving: false
      permissionLevel: 4
      selectedEntity: null
    }

  # NOTE: just to be save, block *implicit* form submits
  # (should normally not be triggered when button[type=button] is used.)
  _onImplicitSumbit: (event) ->
    event.preventDefault()

  _onExplicitSubmit: (event) ->
    event.preventDefault()
    @_submit(event)
    return false

  _submit: (clickEvent) ->
    @setState(saving: true)
    railsFormPut.byForm(@refs.form, (result) =>
      if result.result == 'error'
        window.scrollTo(0, 0)
        @setState(saving: false, errorMessage: result.message)
          # TODO if @isMounted()
      else
        if !@props.batch
          if !result.data.viewable
            location.href = @props.singleResourceFallbackUrl
          else
            location.href = @props.singleResourcePermissionsUrl
        else
          location.reload()
    )


  handleEntitySelect: (entity) ->
    @setState(selectedEntity: entity)

  handleEntityClear: () ->
    @setState(selectedEntity: null)

  _onToggleCheckbox: (level, event) ->
    if level > @state.permissionLevel
      @setState(permissionLevel: level)
    else
      @setState(permissionLevel: level - 1)

  _displayBlockIf: (bool) ->
    if bool
      {display: 'block'}
    else
      {display: 'none'}

  _translateForNResources: (resourceType, n) ->
    if resourceType == 'Collection'
      if n == 1
        interpolateSplit(t('transfer_responsibility_for_1_collection')).join('')
      else
        interpolateSplit(t('transfer_responsibility_for_n_collections'), {nofResources: n}).join('')
    else
      if n == 1
        interpolateSplit(t('transfer_responsibility_for_1_media_entry')).join('')
      else
        interpolateSplit(t('transfer_responsibility_for_n_media_entries'), {nofResources: n}).join('')

  render: ({authToken, currentUser, batch, resourceType, singleResourceUrl, singleResourceActionUrl, 
            batchResourceIds, batchActionUrls, 
            responsible, batchResponsibles,
            onClose} = @props) ->

    actionUrl =
      if not batch
        singleResourceActionUrl
      else
        batchActionUrl = batchActionUrls[resourceType]
        throw new Error('Action url not available for batch type: ' + resourceType) if not batchActionUrl
        batchActionUrl
    
    responsibles =  if batch then batchResponsibles else [ responsible ]

    <div className='bright ui-container pal rounded'>

      <RailsForm ref='form'
        name='transfer_responsibility' action={actionUrl}
        onSubmit={@_onImplicitSumbit}
        method='put' authToken={authToken}>

        {
          if batch
            f.map(batchResourceIds, (resource_id) ->
              <input key={resource_id} type='hidden' name='id[]' value={resource_id} />
            )
        }

        {
          if @state.errorMessage
            <div className='ui-alerts' style={{marginBottom: '10px'}}>
              <div className='error ui-alert'>
                {@state.errorMessage}
              </div>
            </div>
        }


        {
          if batch
            <h2 className='title-l ui-info-box-title mbm'>
              {interpolateSplit(t('transfer_responsibility_title_batch'), 
                {forNResources: @_translateForNResources(resourceType, batchResourceIds.length)})}
            </h2>
          else 
            <h2 className='title-l ui-info-box-title mbm'>{t('transfer_responsibility_title_single')}</h2>
        }

        <div className="title-m ">{t('transfer_responsibility_currently_responsible')}</div>
        <div className="mbm">
          {
            for idx, r of responsibles
              <div key={idx}>
                {r.name}
                {if responsibles.length > 1 
                  " " + @_translateForNResources(resourceType, r.nofResources)}
              </div>
          }
        </div>

        <div className="title-m">{t('transfer_responsibility_to')}</div>
        <div className='ui-rights-user' style={@_displayBlockIf(@state.selectedEntity)}>
          <a onClick={@handleEntityClear}
            className='button small ui-rights-remove icon-close small'
            title={t('permissions_table_remove_subject_btn')} />
          <input type='hidden' name='transfer_responsibility[entity]'
            value={if @state.selectedEntity then @state.selectedEntity.uuid else ''} />
          <input type='hidden' name='transfer_responsibility[type]'
            value={if @state.selectedEntity then @state.selectedEntity.type else ''} />
          <span className='text'>
            {@state.selectedEntity.name if @state.selectedEntity}
          </span>
        </div>

        <div style={@_displayBlockIf(!@state.selectedEntity)}>
          <AutoComplete
            className='block'
            name={'transfer_responsibility[unused_look_at_the_hidden_user]'} resourceType={['Delegations', 'Users']}
            onSelect={@handleEntitySelect} searchParams={{search_also_in_person: true}}
            positionRelative={true} />
        </div>

        <div>
          <h2 className='title-m ui-info-box-title mtm mbs'>
            {
              if responsibles.length == 1
                if responsibles[0].uuid == currentUser.uuid
                  interpolateSplit(t('transfer_responsibility_you_will_receive'), 
                    {name: responsibles[0].name}).join('')
                else
                  interpolateSplit(t('transfer_responsibility_single_will_receive'), 
                    {name: responsibles[0].name}).join('')
              else
                t('transfer_responsibility_multiple_will_receive')
            }
          </h2>
          <table className='ui-rights-group'>
            <tbody>
              <tr>
                <td style={{textAlign: 'center', border: '0px'}}>
                  {t('permission_name_get_metadata_and_previews')}
                </td>
                {
                  if resourceType == 'MediaEntry'
                    <td style={{textAlign: 'center', border: '0px'}}>
                      {t('permission_name_get_full_size')}
                    </td>
                }
                <td style={{textAlign: 'center', border: '0px'}}>
                  {if resourceType == 'Collection' then t('permission_name_edit_metadata_and_relations') else t('permission_name_edit_metadata')}
                </td>
                <td style={{textAlign: 'center', border: '0px'}}>
                  {t('permission_name_edit_permissions')}
                </td>
              </tr>
              <tr>
                <td style={{textAlign: 'center', border: '0px'}}>
                  <input type='checkbox'
                    name={'transfer_responsibility[permissions][view]'}
                    checked={@state.permissionLevel >= 1} onChange={(event) => @_onToggleCheckbox(1, event)} />
                </td>
                {
                  if resourceType == 'MediaEntry'
                    <td style={{textAlign: 'center', border: '0px'}}>
                      <input type='checkbox'
                        name={'transfer_responsibility[permissions][download]'}
                        checked={@state.permissionLevel >= 2} onChange={(event) => @_onToggleCheckbox(2, event)} />
                    </td>
                }
                <td style={{textAlign: 'center', border: '0px'}}>
                  <input type='checkbox'
                    name={'transfer_responsibility[permissions][edit]'}
                    checked={@state.permissionLevel >= 3} onChange={(event) => @_onToggleCheckbox(3, event)} />
                </td>
                <td style={{textAlign: 'center', border: '0px'}}>
                  <input type='checkbox'
                    name={'transfer_responsibility[permissions][manage]'}
                    checked={@state.permissionLevel >= 4} onChange={(event) => @_onToggleCheckbox(4, event)} />
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div className='ui-actions phl pbl mtl'>
          <a className='link weak' onClick={onClose}> {t('transfer_responsibility_cancel')} </a>
          <button disabled={(not @state.selectedEntity) || @state.saving}
            className='primary-button large' onClick={@_onExplicitSubmit} type='button'>
            {t('transfer_responsibility_submit')}
          </button>
        </div>

      </RailsForm>

    </div>
