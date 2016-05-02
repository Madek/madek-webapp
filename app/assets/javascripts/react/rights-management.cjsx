React = require('react')
f = require('active-lodash')
t = require('../lib/string-translation')('de') # TODO: select correct locale!
url = require('url')
ampersandReactMixin = require('ampersand-react-mixin')

AutoComplete = 'div' # only required client-side!

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

  getInitialState: ()-> {editing: false}

  # this will only ever run on the client:
  componentDidMount: ()->
    AutoComplete = require('./lib/autocomplete.cjsx')
    router = require('../lib/router.coffee')

    if @props.get.type == 'Collection'
      PermissionsModel = require('../models/collection/permissions.coffee')
    else
      PermissionsModel = require('../models/media-entry/permissions.coffee')

    model = new PermissionsModel(@props.get)
    editUrl = url.resolve(@props.get.url, 'permissions/edit')

    # set up auto-update for model:
    f.each ['add', 'remove', 'reset', 'change'], (eventName)=>
      model.on(eventName, ()=> @forceUpdate() if @isMounted())

    # set state according to url from router
    router.listen (location)=> # runs once initially when router is started
      @setState
        editing: f.isEqual(location.pathname, editUrl)

    @setState({model: model, router: router})

    # start the router
    router.start()

  startEditing: (event)->
    event?.preventDefault()
    @state.router.goTo(event.target.href)

  cancelEditing: (event)->
    # TODO: handle abort inline (without refresh) und reset state
    # event?.preventDefault()
    # @props.router.goTo(event.target.href)
    # @setState(editing: false, permissions: …)

  submitForm: (event)->
    event.preventDefault()
    @setState(saving: true)
    @state.model.save
      success: (model, res)=>
        # TODO: ui-alert res?.message
        @setState(saving: false, editing: false)
        @state.router.goTo(model.url)
      error: (model, err)=>
        @setState(saving: false, editing: true)
        alert('Error! ' + ((try JSON.stringify(err?.body || err , 0, 2)) or ''))
        console.error(err)


  render: ({get} = @props)->
    {submitForm, cancelEditing} = @
    {editing, saving} = @state
    get = @state.model or get
    editable = get.can_edit

    <form name='ui-rights-management' onSubmit={submitForm}>

      <PermissionsOverview get={get}/>

      <hr className='separator light mvl'/>

      <h3 className='title-l mbs'>{t('permissions_table_title')}</h3>

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
          editing={editing}/>

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
                    onClick={@startEditing}
                    className='primary-button large'>
                    {t('permissions_table_edit_btn')}</a></div>
              when editing
                <div className='ui-actions'>
                  <a className='link weak'
                    href={get.url}
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
            {t('permissions_responsible_user_title')}
          </h2>

          <p className='ui-info-box-intro prm'>
            {t('permissions_responsible_user_msg')}
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

  onAddSubject: (subject)->
    @props.permissionsList.add(subject: subject)

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

        {if editing and permissionsList.isCollection
          <div className='ui-add-subject ptx row'>
            <div className='col1of3'>
              {if type?
                <AutoComplete name={"add_#{type}"} resourceType={type} onSelect={@onAddSubject}/>
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
      isEnabled = f.isBoolean(@props.permissions[permissionType])
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
                # leave the field empty if permission is not possible:
                null
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
