# Permissions View for a single resource, can be show or (inline-)edit
# - has internal router to switch between show/edit by URL

React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation')('de') # TODO: select correct locale!
url = require('url')
ampersandReactMixin = require('ampersand-react-mixin')

ResourcePermissionsForm = require('../decorators/ResourcePermissionsForm.cjsx')

# NOTE: used for static (server-side) rendering (state.editing = false)
module.exports = React.createClass
  displayName: 'ResourcePermissions'

  getInitialState: ()-> {editing: false, saving: false}

  componentWillMount: ()->
    model = if @props.get.isState
      @props.get
    else
      PermissionsModel = if @props.get.type == 'Collection'
        require('../../models/collection/permissions.coffee')
      else
        require('../../models/media-entry/permissions.coffee')
      new PermissionsModel(@props.get)

    # set up auto-update for model:
    f.each ['add', 'remove', 'reset', 'change'], (eventName)=>
      model.on(eventName, ()=> @forceUpdate() if @isMounted())

    @setState({model: model})

  # functions to be called on unmount (cleanup):
  _toBeCalledOnUnmount: []
  componentWillUnMount: ()-> f.each(_toBeCalledOnUnmount, (fn)-> fn())

  # this will only ever run on the client:
  componentDidMount: ()->
    AutoComplete = require('../lib/autocomplete.cjsx')
    router = require('../../lib/router.coffee')

    editUrl = url.resolve(@props.get.url, 'permissions/edit')

    # setup router:

    # set state according to url from router
    stopListen = router.listen((location)=> # runs once initially when router is started!
      @setState({editing: f.isEqual(location.pathname, editUrl)}))
    @_toBeCalledOnUnmount.push(stopListen)

    stopConfirming = router.confirmNavigation(
      check: ()=> @state.editing || @state.saving)
    @_toBeCalledOnUnmount.push(stopConfirming)

    # "attach" and start the router
    @_router = router # internal ref, NOT in state!
    router.start()

  _onStartEdit: (event)->
    event?.preventDefault()
    @_router.goTo(event.target.href)

  _onCancelEdit: (event)->
    # TODO: handle abort inline (without refresh) und reset state
    # event?.preventDefault()
    # @props.router.goTo(event.target.href)
    # @setState(editing: false, permissions: …)

  _onSubmitForm: (event)->
    event.preventDefault()
    @setState(saving: true)
    @state.model.save
      success: (model, res)=>
        # TODO: ui-alert res?.message
        @setState(saving: false, editing: false)
        @_router.goTo(model.url)
      error: (model, err)=>
        @setState(saving: false, editing: true)
        alert('Error! ' + ((try JSON.stringify(err?.body || err , 0, 2)) or ''))
        console.error(err)


  render: ()->
    {model, editing, saving} = @state

    <ResourcePermissionsForm
      get={model} editing={editing} saving={saving}
      onEdit={@_onStartEdit} onSubmit={@_onSubmitForm} onCancel={@_onCancelEdit}>

      <PermissionsOverview get={model}/>

      <hr className='separator light mvl'/>

      <h3 className='title-l mbs'>{t('permissions_table_title')}</h3>

    </ResourcePermissionsForm>

#

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
