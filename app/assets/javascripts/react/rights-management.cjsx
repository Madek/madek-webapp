React = require('react')
f = require('../lib/fun.coffee')
ampersandReactMixin = require('ampersand-react-mixin')

# TMP: function to use text markers in a compatible syntax and collect text here:
t = i18n = (marker)->
  translations = {
    # component-specific:
    permissions_table_title: 'Berechtigungen'
    permissions_table_edit_btn: 'Bearbeiten'
    permissions_table_save_btn: 'Speichern'
    permissions_table_cancel_btn: 'Abbrechen'
    permissions_table_remove_subject_btn: 'Berechtigung entfernen'
    permissions_overview_yours_title: 'Ihre Berechtigungen'
    permissions_overview_yours_msg_start: 'Sie, '
    permissions_overview_yours_msg_end: ', haben gegenwärtig als Person oder als Mitglied einer Gruppe folgende Berechtigungen'
    # general:
    responsible_user_title: 'Verantwortliche Person'
    responsible_user_msg: 'Die verantwortliche Person hat alle Berechtigungen zu den ausgewählten Inhalten und kann diese auch löschen.'
    permission_subject_title_users: 'Personen'
    permission_subject_title_groups: 'Gruppen'
    permission_subject_title_apiapps: 'API-Applikationen'
    permission_subject_title_public: 'Öffentlichkeit'
    permission_subject_name_public: 'Internet'
    permission_name_get_metadata_and_previews: 'Betrachten'
    permission_name_get_full_size: 'Original exportieren & in PDF blättern'
    permission_name_edit_metadata: 'Metadaten editieren & Inhalte zu Set hinzufügen'
    permission_name_edit_permissions: 'Zugriffsberechtigungen ändern'
    permission_overridden_by_public: '(überschrieben durch die Öffentlichen Berechtigungen)'
  }
  f(translations[marker]).presence() or "⟨#{marker}⟩"


UserIndex = React.createClass
  render: ()->
    # TODO: current_user: <i className='current-user-icon icon-privacy-private'></i>#
    <span>{@props.get.name}</span>

GroupIndex = React.createClass
  render: ()->
    # TODO: group icon?
    <span>{@props.get.name}</span>

ApiClientIndex = React.createClass
  render: ()-> <span>{@props.get.login}</span>


# NOTE: used for static (server-side) rendering (state.editing = false)
module.exports = React.createClass
  displayName: 'RightsManagement'
  mixins: [ampersandReactMixin]

  getInitialState: ()-> {editing: false}

  startEditing: (event)->
    event.preventDefault()
    @setState(editing: true)
    @props.callbacks.onStartEditing?()

  cancelEditing: (event)->
    event.preventDefault()
    @setState(editing: false)
    @props.callbacks.onStopEditing?()

  submitForm: (event)->
    event.preventDefault()
    @setState(saving: true)
    @props.permissions.save
      success: (model, res)=>
        # TODO: ui-alert res?.message
        @setState(saving: false, editing: false)
        @props.callbacks.onStopEditing?()
      error: (model, err)=>
        @setState(saving: false, editing: true)
        alert('Error! ' + ((try JSON.stringify(err,0,2)) or ''))
        console.error(err)


  render: ()->
    {submitForm, cancelEditing} = @
    get = @props.permissions
    {editing, saving} = @state
    editable = get.can_edit

    <form name='ui-rights-management' onSubmit={submitForm}>

      <PermissionsOverview get={get}/>

      <hr className='separator light mvl'/>

      <h3 className='title-l mbs'>{t('permissions_table_title')}</h3>

      <div className='ui-rights-management'>
        {# User permissions #}
        <PermissionsBySubjectType type={'User'}
          showTitles={true}
          title={t('permission_subject_title_users')}
          icon='privacy-private-alt'
          SubjectDeco={UserIndex}
          permissionsList={get.user_permissions}
          permissionTypes={get.permission_types}
          overriddenBy={get.public_permission}
          editing={editing}/>

        {# Groups permissions #}
        <PermissionsBySubjectType type={'Group'}
          SubjectDeco={GroupIndex}
          title={t('permission_subject_title_groups')}
          icon='privacy-group-alt'
          permissionsList={get.group_permissions}
          permissionTypes={get.permission_types}
          overriddenBy={get.public_permission}
          editing={editing}/>

        {# ApiApp permissions — hidden on show if empty; always visible on edit #}
        {if (editing or get.api_client_permissions.length > 0)
          <PermissionsBySubjectType type={'ApiClient'}
            title={t('permission_subject_title_apiapps')}
            icon='api'
            SubjectDeco={ApiClientIndex}
            permissionsList={get.api_client_permissions}
            permissionTypes={get.permission_types}
            overriddenBy={get.public_permission}
            editing={editing}/>
        }

        {# Public permissions #}
        <PermissionsBySubjectType
          title={t('permission_subject_title_public')}
          subjectName={t('permission_subject_name_public')}
          icon='privacy-open'
          permissionsList={[get.public_permission]}
          permissionTypes={get.permission_types}
          editing={editing}/>

      </div>

      <div className='ptl'>
        <div className='form-footer'>
            {switch
              when editable and not editing
                <div className='ui-actions'>
                  <a href='permissions/edit'
                    onClick={@startEditing}
                    className='primary-button large'>
                    {t('permissions_table_edit_btn')}</a></div>
              when editing
                <div className='ui-actions'>
                  <a className='link weak'
                    href='.'
                    onClick={@cancelEditing}>
                    {t('permissions_table_cancel_btn')}
                  </a>
                  <button className='primary-button large' disabled={saving}>
                    {t('permissions_table_save_btn')}</button></div>
            }
          </div></div>
    </form>

PermissionsOverview = React.createClass
  mixins: [ampersandReactMixin]
  render: ()->
    {get} = @props

    <div className='row'>
      <div className='col1of2'>
        <div className='ui-info-box'>
          <h2 className='title-l ui-info-box-title'>
            {t('responsible_user_title')}
          </h2>

          <p className='ui-info-box-intro prm'>
            {t('responsible_user_msg')}
          </p>

          <ul className='inline'>
            <li className='person-tag'>
              {get.responsible.name}
            </li>
          </ul>
        </div>
      </div>

      {if get.current_user
        <div className='col1of2'>
          <h2 className='title-l ui-info-box-title'>
            {t('permissions_overview_yours_title')}
          </h2>

          <p className='ui-info-box-intro'>
            {t('permissions_overview_yours_msg_start')}
            {get.current_user.name}
            {t('permissions_overview_yours_msg_end')}
          </p>

          <ul className='inline'>
            {get.current_user_permissions.map (p)->
              <li key={p}>{t("permission_name_#{p}")}</li>
            }
          </ul>
        </div>
      }
    </div>

PermissionsBySubjectType = React.createClass
  displayName: 'PermissionsBySubjectType'
  mixins: [ampersandReactMixin]
  render: ()->
    {type, title, icon, permissionsList, SubjectDeco, subjectName,
    permissionTypes, overriddenBy, editing, showTitles} = @props
    showTitles ||= false

    <div className='ui-rights-management-users'>
      <div className='ui-rights-body'>
        <table className='ui-rights-group'>
          <PermissionsSubjectHeader name={title} icon={icon}
            titles={permissionTypes} showTitles={showTitles}/>
          <tbody>
            {permissionsList.map (permissions)->
              subject = permissions.subject or subjectName

              <PermissionsSubject key={subject.uuid or 'pub'}
                permissions={permissions}
                subject={subject}
                SubjectDeco={SubjectDeco}
                overriddenBy={overriddenBy}
                permissionTypes={permissionTypes}
                editing={editing}/>
            }
          </tbody>
        </table>

        {if editing and permissionsList.isCollection # TODO: add a subject:
          <div className='ui-add-subject ptx row'>
            <div className='col1of3'>
              <input autoComplete='off' className='small block ui-autocomplete-input'
                name='user' placeholder='Name der Person'
                type='text'/>
            </div>
          </div>
        }

      </div></div>

PermissionsSubjectHeader = React.createClass
  render: ()->
    {name, icon, titles, showTitles} = @props
    <thead>
      <tr>
        <td className='ui-rights-user-title'>
          {name} <i className={"icon-#{icon}"}></i>
        </td>
        {titles.map (name)->
          <td className='ui-rights-check-title' key={name}>
            {showTitles && t("permission_name_#{name}")}
          </td>
        }
      </tr>
    </thead>

PermissionsSubject = React.createClass
  mixins: [ampersandReactMixin]

  onPermissionChange: (name, event)->
    value = event.target.checked
    @props.permissions[name] = value

  onSubjectRemove: (_event)-> @props.permissions.destroy()

  render: ()->
    {permissions, overriddenBy, subject, permissionTypes,
    SubjectDeco, editing} = @props
    {onPermissionChange, onSubjectRemove} = @

    <tr>
      <td className='ui-rights-user'>
        {if editing and permissions.subject?
          <RemoveButton onClick={onSubjectRemove}/>
        }
        <span className='text'>
          {if SubjectDeco
            <SubjectDeco get={subject}/>
          else
            subject
          }
        </span>
      </td>

      {permissionTypes.map (name)->
        isEnabled = f.isBoolean(permissions[name])
        isOn = permissions[name]
        isOverridden = overriddenBy[name] if overriddenBy?
        title = t("permission_name_#{name}")
        if isOverridden
          title += ' ' + t('permission_overridden_by_public')
        else if not isEnabled
          title += ' ' + t('permission_disabled_for_subject')

        <td className='ui-rights-check view' key={name}>
          <label className='ui-rights-check-label'>
            {switch
              when not isEnabled
                <i className='icon-close mid' title={title}/>
              when isOverridden
                <i className='icon-privacy-open' title={title}/>
              when editing
                <input type='checkbox' checked={isOn}
                  onChange={f.curry(onPermissionChange)(name)}
                  name={name} title={title}/>
              when isOn
                <i className='icon-checkmark' title={title}/>
              when not isOn
                <i className='icon-close' title={title}/>
            }
          </label>
        </td>
      }
    </tr>

RemoveButton = React.createClass
  render: ()->
    <a onClick={f(@props.onClick).presence()}
      className='button small ui-rights-remove icon-close small'
      title={t('permissions_table_remove_subject_btn')} />