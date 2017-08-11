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

module.exports = React.createClass
  displayName: 'Shared.EditTransferResponsibility'

  getInitialState: () ->
    {
      saving: false
      permissionLevel: 4
      selectedUser: null
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


  _onSelectUser: (user) ->
    if user.uuid != @props.responsibleUuid
      @setState(selectedUser: user)

  _onClearUser: (user) ->
    @setState(selectedUser: null)

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


  render: ({authToken, batch, resourceType, singleResourceUrl, singleResourceActionUrl, batchResourceIds, batchActionUrls} = @props) ->

    actionUrl =
      if not batch
        singleResourceActionUrl
      else
        batchActionUrl = batchActionUrls[resourceType]
        throw new Error('Action url not available for batch type: ' + resourceType) if not batchActionUrl
        batchActionUrl

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


        <h2 className='title-l ui-info-box-title mbm'>{t('transfer_responsibility_title')}</h2>

        <div className='ui-rights-user' style={@_displayBlockIf(@state.selectedUser)}>
          <a onClick={@_onClearUser}
            className='button small ui-rights-remove icon-close small'
            title={t('permissions_table_remove_subject_btn')} />
          <input type='hidden' name='transfer_responsibility[user]'
            value={if @state.selectedUser then @state.selectedUser.uuid else ''} />
          <span className='text'>
            {@state.selectedUser.name if @state.selectedUser}
          </span>
        </div>

        <div style={@_displayBlockIf(!@state.selectedUser)}>
          <AutoComplete
            valueFilter={(value) => value.uuid == @props.responsibleUuid}
            className='block'
            name={'transfer_responsibility[unused_look_at_the_hidden_user]'} resourceType={'Users'}
            onSelect={@_onSelectUser} searchParams={{search_also_in_person: true}}
            positionRelative={true} />
        </div>

        <h2 className='title-m ui-info-box-title mtl mbm separated light'>
          {t('transfer_responsibility_person_will_receive_1')}
          {@props.responsible.name}
          {t('transfer_responsibility_person_will_receive_2')}
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
                {if @props.resourceType == 'Collection' then t('permission_name_edit_metadata_and_relations') else t('permission_name_edit_metadata')}
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

        <div className='ui-actions phl pbl mtl'>
          <a className='link weak' onClick={@props.onClose}> {t('transfer_responsibility_cancel')} </a>
          <button disabled={(not @state.selectedUser) || @state.saving}
            className='primary-button large' onClick={@_onExplicitSubmit} type='button'>
            {t('transfer_responsibility_submit')}
          </button>
        </div>

      </RailsForm>

    </div>
