# Permissions Form for single or batch resources

React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation')('de') # TODO: select correct locale!
ampersandReactMixin = require('ampersand-react-mixin')

AutoComplete = 'div' # only required client-side!

# NOTE: used for static (server-side) rendering (state.editing = false)
module.exports = React.createClass
  displayName: 'ResourcePermissionsForm'
  mixins: [ampersandReactMixin]

  getDefaultProps: ()->
    children: null
    onSubmit: ()-> # noop

  # this will only ever run on the client:
  componentDidMount: ()->
    # init autocompletes, then force re-render:
    AutoComplete = require('../lib/autocomplete.cjsx')
    @forceUpdate() if @isMounted

  render: ({get, children, editing, saving, onEdit, onSubmit, onCancel} = @props)->
    editable = get.can_edit

    <form name='ui-rights-management' onSubmit={onSubmit}>

      {children}

      <div className='ui-rights-management'>
        {# User permissions #}
        <PermissionsBySubjectType type={'Users'}
          showTitles={true}
          title={t('permission_subject_title_users')}
          icon='privacy-private-alt'
          SubjectDeco={UserIndex}
          permissionsList={get.user_permissions}
          permissionTypes={get.permission_types}
          overriddenBy={get.public_permission}
          editing={editing}/>

        {# Groups permissions #}
        <PermissionsBySubjectType type={'Groups'}
          SubjectDeco={GroupIndex}
          title={t('permission_subject_title_groups')}
          icon='privacy-group-alt'
          permissionsList={get.group_permissions}
          permissionTypes={get.permission_types}
          overriddenBy={get.public_permission}
          editing={editing}
          searchParams={{scope: 'permissions'}} />

        {# ApiApp permissions — hidden on show if empty; always visible on edit #}
        {if (editing or get.api_client_permissions.length > 0)
          <PermissionsBySubjectType type={'ApiClients'}
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
                    onClick={onEdit}
                    className='primary-button large'>
                    {t('permissions_table_edit_btn')}</a></div>
              when editing and (onCancel or onSubmit)
                <div className='ui-actions'>
                  {if onCancel
                    <a className='link weak'
                      href={get.url}
                      onClick={onCancel}>
                      {t('permissions_table_cancel_btn')}
                    </a>}
                  {if onSubmit
                    <button className='primary-button large' disabled={saving}>
                      {t('permissions_table_save_btn')}</button>}
                </div>
            }
          </div></div>
    </form>

PermissionsBySubjectType = React.createClass
  displayName: 'PermissionsBySubjectType'
  mixins: [ampersandReactMixin]

  onAddSubject: (subject)->
    @props.permissionsList.add(subject: subject)

  render: ()->
    {type, title, icon, permissionsList, SubjectDeco, subjectName,
    permissionTypes, overriddenBy, editing, showTitles, searchParams} = @props
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

        {if editing and permissionsList.isCollection
          <div className='ui-add-subject ptx row'>
            <div className='col1of3'>
              {if type?
                <AutoComplete name={"add_#{type}"} resourceType={type}
                  onSelect={@onAddSubject} searchParams={searchParams} />
              }
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

  adjustCheckboxesDependingOnStrength: (name, stronger) ->
    beforeCurrent = true
    for i, permissionType of @props.permissionTypes
      isEnabled = f.present(@props.permissions[permissionType])
      isCurrent = permissionType is name
      beforeCurrent = false if isCurrent
      if not isCurrent and isEnabled
        if beforeCurrent and stronger
          @props.permissions[permissionType] = true
        if not beforeCurrent and not stronger
          @props.permissions[permissionType] = false

  setWeakerUnchecked: (name) ->
    @adjustCheckboxesDependingOnStrength(name, true)

  setStrongerChecked: (name) ->
    @adjustCheckboxesDependingOnStrength(name, false)


  onPermissionChange: (name, event)->
    value = event.target.checked
    @props.permissions[name] = value
    if value is true
      @setWeakerUnchecked(name)
    else
      @setStrongerChecked(name)

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
        isEnabled = f.present(permissions[name])
        curState = permissions[name] # true/false/mixed
        isOverridden = if overriddenBy then (overriddenBy[name] == true) else false
        title = t("permission_name_#{name}")
        if isOverridden
          title += ' ' + t('permission_overridden_by_public')
        else if not isEnabled
          title += ' ' + t('permission_disabled_for_subject')

        <td className='ui-rights-check view' key={name}>
          <label className='ui-rights-check-label'>
            {switch
              when not isEnabled
                # leave the field empty if permission is not possible:
                null
              when isOverridden
                <i className='icon-privacy-open' title={title}/>
              when editing
                <TristateCheckbox checked={curState}
                  onChange={f.curry(onPermissionChange)(name)}
                  name={name} title={title}/>
              when curState is true
                <i className='icon-checkmark' title={title}/>
              when curState is false
                <i className='icon-close' title={title}/>
            }
          </label>
        </td>
      }
    </tr>

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

RemoveButton = React.createClass
  render: ()->
    <a onClick={f(@props.onClick).presence()}
      className='button small ui-rights-remove icon-close small'
      title={t('permissions_table_remove_subject_btn')} />

TristateCheckbox = React.createClass
  propTypes: {checked: React.PropTypes.oneOf([true, false, 'mixed'])}
  getDefaultProps: ()->
    onChange: ()-> # noop

  # NOTE: 'indeterminate' is a node attribute (not a prop!),
  # need to set on mount and every re-render!!
  _setIndeterminate: ()->
    isMixed = !f.isBoolean(this.props.checked)
    if this._inputNode # <- only if it's mounted…
      this._inputNode.indeterminate = isMixed
  _inputNode: null
  componentDidUpdate: ()-> this._setIndeterminate()

  render: (props = this.props)->
    restProps = f.omit(props, ['checked'])
    isMixed = !f.isBoolean(props.checked)
    <input type='checkbox'
      {...restProps}
      checked={if isMixed then false else props.checked}
      ref={((inputNode)=>
        this._inputNode = inputNode
        this._setIndeterminate())}
    />
