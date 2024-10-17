# Permissions Form for single or batch resources

React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js') # TODO: select correct locale!
ampersandReactMixin = require('ampersand-react-mixin')

# NOTE: used for static (server-side) rendering (state.editing = false)
AutoComplete = null # only required client-side!

# Subject Decorators (overidable by props for custom render)
defaultSubjectDecos = {
  User: ({subject})->
    # TODO: current_user: <i className='current-user-icon icon-privacy-private'></i>#
    <span className='text'>{subject.name}</span>

  Group: ({subject})->
    # TODO: group icon?
    <span className='text'>{subject.detailed_name}</span>

  ApiClient: ({subject})->
    <span className='text'>{subject.login}</span>

  Public: ({subject})-> <span>{subject}</span>
}

doOptionalsInclude = (optionals, type) ->
  types = if f.isArray(type) then type else [type]
  f.some(types, (t) => f.contains(optionals, t))

module.exports = React.createClass
  displayName: 'ResourcePermissionsForm'
  mixins: [ampersandReactMixin]

  getDefaultProps: ()->
    children: null
    onSubmit: ()-> # noop
    decos: defaultSubjectDecos
    optionals: ['ApiClients']

  # this will only ever run on the client:
  componentDidMount: ()->
    @_isMounted = true
    # init autocompletes, then force re-render:
    AutoComplete = require('../lib/autocomplete.js')
    @forceUpdate() if @_isMounted

  componentWillUnmount: () ->
    @_isMounted = false

  render: ({get, children, editing, saving, onEdit, onSubmit, onCancel, optionals, decos} = @props)->
    editable = get.can_edit
    user_permissions_title = if get.type is 'Vocabulary'
      t('permission_subject_title_users')
    else
      t('permission_subject_title_users_or_delegations')

    rows = [
      { # User permissions
        type: ['Users', 'Delegations']
        title: user_permissions_title
        icon: 'privacy-private-alt'
        SubjectDeco: decos.Users || defaultSubjectDecos.User
        permissionsList: get.user_permissions
        overriddenBy: get.public_permission
      },

      { # Groups permissions
        type: 'Groups'
        title: t('permission_subject_title_groups')
        icon: 'privacy-group-alt'
        SubjectDeco: decos.Groups || defaultSubjectDecos.Group
        permissionsList: get.group_permissions
        overriddenBy: get.public_permission
        searchParams: {scope: 'permissions'}
      },

      { # ApiApp permissions
        type: 'ApiClients'
        title: t('permission_subject_title_apiapps')
        icon: 'api'
        SubjectDeco: decos.ApiClients || defaultSubjectDecos.ApiClient
        permissionsList: get.api_client_permissions
        overriddenBy: get.public_permission
      }

      # Public permissions
      {
        title: t('permission_subject_title_public')
        subjectName: t('permission_subject_name_public')
        icon: 'privacy-open'
        SubjectDeco: decos.Public || defaultSubjectDecos.Public
        permissionsList: [get.public_permission]
        permissionTypes: get.permission_types
      }
    ]
    rows = f.reject(rows, ({type, permissionsList})->
      # optionals: hidden on show if empty; always visible on edit
      !editing && type && doOptionalsInclude(optionals, type) && (permissionsList.length < 1)
    )

    <form name='ui-rights-management' onSubmit={onSubmit}>

      {children}

      <div className='ui-rights-management'>

        {rows.map((row, i) ->
          showTitles = (i == 0) # show titles on first table only
          <PermissionsBySubjectType
            {...row}
            key={i}
            showTitles={showTitles}
            editing={editing}
            permissionTypes={get.permission_types}
          />
        )}

      </div>

      <div className='ptl'>
        <div className='form-footer'>
            {switch
              when editable and not editing
                <div className='ui-actions'>
                  <a href={@props.editUrl}
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
    list = @props.permissionsList
    return if f.includes(f.map(list.models, 'subject.uuid'), subject.uuid)
    list.add(subject: subject)

  render: ()->
    {type, title, icon, permissionsList, SubjectDeco, subjectName,
    permissionTypes, overriddenBy, editing, showTitles, searchParams} = @props
    showTitles ||= false

    <div className={'ui-rights-management-users' + if editing then ' ui-rights-management-editing'}>
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
          <div className='ui-add-subject ptx'>
            <div className='col1of3' style={position: 'relative', maxWidth: '300px'}>
              {if type? and AutoComplete
                <AutoComplete
                  className='block'
                  name={"add_#{type}"}
                  resourceType={type}
                  valueFilter={({uuid}) ->
                    f.includes(f.map(permissionsList.models, 'subject.uuid'), uuid)
                  }
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
        <SubjectDeco subject={subject}/>
      </td>

      {permissionTypes.map (name)->
        isEnabled = f.present(permissions[name])
        curState = permissions[name] # true/false/mixed
        isOverridden = if overriddenBy then (overriddenBy[name] == true) else false
        title = t("permission_name_#{name}")

        <td className='ui-rights-check view' key={name}>
            {
              if not isEnabled
                # leave the field empty if permission is not possible:
                null
              else
                <span className="ui-rights-check-container">
                  {if isOverridden
                    title += ' ' + t('permission_overridden_by_public')
                    <i className='icon-privacy-open' title={title} />
                  }
                  {if editing
                    <label className='ui-rights-check-label' >
                      <TristateCheckbox checked={curState}
                        onChange={f.curry(onPermissionChange)(name)}
                        name={name} title={title}/>
                    </label>
                  else
                    if curState is true
                      <i className='icon-checkmark' title={title} />
                    else
                      <span className='pseudo-icon-dash' title={title} >—</span>
                  }
                </span>
            }
        </td>
      }
    </tr>

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
