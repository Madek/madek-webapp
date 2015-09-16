React = require('react')
f = require('../lib/fun.coffee')

# TMP: function to use text markers in a compatible syntax and collect text here:
t = i18n = (marker)->
  translations = {
    # component-specific:
    permissions_table_title: 'Berechtigungen'
    responsible_user_title: 'Verantwortliche Person'
    responsible_user_msg: 'Die verantwortliche Person hat alle Berechtigungen zu den ausgewählten Inhalten und kann diese auch löschen.'
    remove_subject: 'Berechtigung entfernen'
    permissions_overview_yours_title: 'Ihre Berechtigungen'
    permissions_overview_yours_msg_start: 'Sie, '
    permissions_overview_yours_msg_end: ', haben gegenwärtig als Person oder als Mitglied einer Gruppe folgende Berechtigungen'
    # general:
    permission_subject_title_users: 'Personen'
    permission_subject_title_groups: 'Gruppen'
    permission_subject_title_apiapps: 'API-Applikationen'
    permission_subject_title_public: 'Öffentlichkeit'
    permission_subject_name_public: 'Internet'
    permission_name_get_metadata_and_previews: 'Betrachten'
    permission_name_get_full_size: 'Original exportieren & in PDF blättern'
    permission_name_edit_metadata: 'Metadaten editieren & Inhalte zu Set hinzufügen'
    permission_name_edit_permissions: 'Zugriffsberechtigungen ändern'
    permissions_table_title_overridden_msg: '(überschrieben durch die Öffentlichen Berechtigungen)'
  }
  f(translations[marker]).presence() or "⟨#{marker}⟩"

# TODO: group icon
# GroupText = React.createClass
#   displayName: 'UserText'
#   render: ()->
#     {get} = @props
#     <span><icon/> {text}</span>

# NOTE: used for static rendering (state.editing = false)
module.exports = React.createClass
  displayName: 'RightsManagement'

  render: ()->
    {permissions, server} = @props
    get = permissions

    editable = permissions.can_edit

    editing = false # TODO: @state

    subjects = {
      users:
        name: t('permission_subject_title_users')
        icon: 'privacy-private-alt'
        permissions: get.user_permissions.map (p)->
          f.merge {}, p, {
            subject: p.person_name # already a PersonPresenter
          }
      groups:
        name: t('permission_subject_title_groups')
        icon: 'privacy-group-alt'
        permissions: get.group_permissions.map (p)->
          f.merge {}, p, {
            subject: { name: p.group_name, uuid: p.group_id }
          }
      apiapps:
        name: t('permission_subject_title_apiapps')
        icon: 'api'
        permissions: get.api_client_permissions.map (p)->
          f.merge {}, p, {
            subject: { name: p.api_client_login, uuid: p.api_client_id }
          }
      public:
        name: t('permission_subject_title_public')
        icon: 'privacy-open'
        permissions: [
          f.merge {}, get.public_permission, {
            subject: { name: t('permission_subject_name_public') }
          }
        ]
      }

    <form id='ui-rights-management' name='ui-rights-management'>

      <PermissionsOverview get={get}/>

      <hr className='separator light mvl'/>

      <h3 className='title-l mbs'>{t('permissions_table_title')}</h3>

      <div className='ui-rights-management'>
        {# User permissions #}
        <PermissionsSubjectRow showTitles={true}
          subject={subjects['users']}
          permissionTypes={get.permission_types}
          overriddenBy={get.public_permission}
          editing={editing}/>

        {# Groups permissions #}
        <PermissionsSubjectRow
          subject={subjects['groups']}
          permissionTypes={get.permission_types}
          overriddenBy={get.public_permission}
          editing={editing}/>

        {# ApiApp permissions — hidden on show if empty; always visible on edit #}
        {if (editing or get.api_client_permissions.length > 0)
          <PermissionsSubjectRow
            subject={subjects['apiapps']}
            permissionTypes={get.permission_types}
            overriddenBy={get.public_permission}
            editing={editing}/>
        }

        {# Public permissions #}
        <PermissionsSubjectRow
          subject={subjects['public']}
          permissionTypes={get.permission_types}
          editing={editing}/>
      </div>

      <div className='ptl'>
        <div className='form-footer'>
          <div className='ui-actions'>
            {unless editing
              if editable
                <a href='permissions/edit'
                  className='primary-button large'>Edit</a>
            else
              <a className='link weak' href='..' title='Abbrechen'>Abbrechen</a>
              <button className='primary-button large'
                type='submit'>Speichern</button>
            }
          </div>
        </div>
      </div>

    </form>

PermissionsOverview = React.createClass
  displayName: 'PermissionsOverview'
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
    </div>

PermissionsSubjectRow = React.createClass
  displayName: 'PermissionsSubjectRow'
  render: ()->
    {subject, permissionTypes, overriddenBy, editing, showTitles} = @props
    permissions = subject.permissions
    showTitles ||= false

    <div className='ui-rights-management-users'>
      <div className='ui-rights-body'>
        <table className='ui-rights-group'>

          <thead>
            <tr>
              <td className='ui-rights-user-title'>
                {subject.name} <i className={"icon-#{subject.icon}"}></i>
              </td>
              {permissionTypes.map (name)->
                <td className='ui-rights-check-title' key={name}>
                  {showTitles && t("permission_name_#{name}")}
                </td>
              }
            </tr>
          </thead>

          <tbody>
            {permissions.map (permission)->
              {subject, permissions} = permission

              <tr key={permission.subject.uuid or 'pub'}>
                <td className='ui-rights-user'>
                  {if editing
                    <RemoveButton/>
                  }
                  <span className='text'>
                    <i className='current-user-icon icon-privacy-private'></i>
                    {subject.name}
                  </span>
                </td>

                {permissionTypes.map (name)->
                  isOn = permission[name]
                  isOverridden = overriddenBy[name] if overriddenBy?

                  title = t("permission_name_#{name}")
                  if isOverridden
                    title += ' ' + t('permissions_table_title_overridden_msg')

                  <td className='ui-rights-check view' key={name}>
                    <label className='ui-rights-check-label'>
                      {if isOverridden
                        <i className='icon-privacy-open' title={title}></i>
                      else
                        <input type='checkbox' checked={isOn}
                          readOnly={not editing} disabled={not editing}
                          name={name} title={title}/>
                      }
                    </label>
                  </td>
                }
              </tr>
            }
          </tbody>
        </table>

        {if editing
          <div className='ui-add-subject ptx row' id='addUser'>
            <div className='col1of3'>
              <input autocomplete='off' className='small block ui-autocomplete-input'
                name='user' placeholder='Name der Person'
                type='text'/>
            </div>
          </div>
        }

      </div>
    </div>


RemoveButton = React.createClass
  render: ()->
    <a onClick={f(@props.onClick).presence()}
      className='button small ui-rights-remove icon-close small'
      title={t('remove_subject')} />
