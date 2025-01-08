React = require('react')
f = require('active-lodash')
defaultsDeep = require('lodash/defaultsDeep')
fromPairs = require('lodash/fromPairs')
ampersandReactMixin = require('ampersand-react-mixin')
ui = require('../lib/ui.js')
{parseMods, cx} = ui
t = ui.t
setUrlParams = require('../../lib/set-params-for-url.js')
parseUrl = require('url').parse
stringifyUrl = require('url').format
parseQuery = require('qs').parse
Selection = require('../../lib/selection.js')
resourceListParams = require('../../shared/resource_list_params.js')
appRequest = require('../../lib/app-request.js')

Waypoint = require('react-waypoint')
RailsForm = require('../lib/forms/rails-form.cjsx')
{ Button, ButtonGroup, Icon, Link, Preloader, Dropdown, ActionsBar
} = require('../ui-components/index.js')
MenuItem = Dropdown.MenuItem
SideFilter = require('../ui-components/ResourcesBox/SideFilter.cjsx')
BoxToolBar = require('../ui-components/ResourcesBox/BoxToolBar.cjsx')

# models
MediaEntries = require('../../models/media-entries.js')
Collections = require('../../models/collections.js')
CollectionChildren = require('../../models/collection-children.js')

# interactive stuff, should be moved to controller
xhr = require('xhr')
getRailsCSRFToken = require('../../lib/rails-csrf-token.js')
BatchAddToSetModal = require('./BatchAddToSetModal.cjsx')
BatchRemoveFromSetModal = require('./BatchRemoveFromSetModal.cjsx')

simpleXhr = require('../../lib/simple-xhr.js')

LoadXhr = require('../../lib/load-xhr.js')
Preloader = require('../ui-components/Preloader.cjsx')

ActionsDropdown = require('./resourcesbox/ActionsDropdown.cjsx')
Clipboard = require('./resourcesbox/Clipboard.cjsx')

railsFormPut = require('../../lib/form-put-with-errors.js')

setsFallbackUrl = require('../../lib/sets-fallback-url.js')
libUrl = require('url')
qs = require('qs')

BoxUtil = require('./BoxUtil.js')

BoxSetUrlParams = require('./BoxSetUrlParams.jsx')

BoxBatchEdit = require('./BoxBatchEdit.js')
BoxBatchEditForm = require('./BoxBatchEditForm.jsx')

BoxRedux = require('./BoxRedux.js')
BoxState = require('./BoxState.js')

BoxFilterButton = require('./BoxFilterButton.jsx')
CreateCollectionModal = require('../views/My/CreateCollectionModal.cjsx')

resourceTypeSwitcher = require('../lib/resource-type-switcher.cjsx').resourceTypeSwitcher

InfoHeader = require('./resourcesbox/InfoHeader.jsx').default

# Props/Config overview:
# - props.get.has_user = should the UI offer any interaction
# - state.isClient = is component in client-side mode
# - props.get.can_filter = is it possible to filter the resources
# - props.get.filter = the currently active filter
# - props.get.config.show_filter = if the filterBar should be shown

getLocalLink = (event) ->
  localLinks = require('local-links')
  return localLinks.pathname(event)

routerGoto = (path) ->
  url = require('url')
  History = require('history/lib/createBrowserHistory')
  useBeforeUnload = require('history/lib/useBeforeUnload')
  history = useBeforeUnload(History)()
  history.push(url.parse(path)?.path)

isNewTab = (event) ->
  localLinks = require('local-links')
  if (internalLink = localLinks.pathname(event))
    return false
  else
    return true

module.exports = React.createClass
  displayName: 'MediaResourcesBox'
  propTypes: require('./BoxPropTypes.js').propTypes()

  getDefaultProps: ()->
    fallback: true

  # kick of client-side mode:
  getInitialState: ()-> {
    isClient: false,
    clipboardModal: 'hidden',
    batchAddToSet: false,
    batchRemoveFromSet: false,
    savedLayout: @props.collectionData.layout if @props.collectionData
    savedOrder: @props.collectionData.order if @props.collectionData
    savedContextId: f.get(@props, 'collectionData.defaultContextId')
    savedResourceType: @props.collectionData?.defaultResourceType
    showBatchTransferResponsibility: false
    batchTransferResponsibilityResources: []
    batchDestroyResourcesModal: false
    batchDestroyResourcesWaiting: false
    showSelectionLimit: false
    boxState: this.initialBoxState({})
    showCreateCollectionModal: false
  }

  doOnUnmount: [] # to be filled with functions to be called on unmount
  componentWillUnmount: ()->
    f.each(f.compact(@doOnUnmount), (fn)->
      if f.isFunction(fn) then fn() else console.error("Not a Function!", fn))


  initialBoxState: (event) ->
    props = {get: @props.get}

    return BoxState(
      {
        event: {},
        trigger: @triggerComponentEvent,
        initial: true,
        components: {},
        data: {},
        nextProps: props,
        path: []
      }
    )

  nextBoxState: (events) ->
    merged = BoxRedux.mergeStateAndEventsRoot(@state.boxState, events)

    props = {
      get: @_mergeGet(@props, @state),
      currentUrl: @_currentUrl(),
      getJsonPath: @getJsonPath
    }

    boxState = BoxState(
      {
        event: merged.event,
        trigger: @triggerComponentEvent,
        initial: false,
        components: merged.components,
        data: merged.data,
        nextProps: props,
        path: []
      }
    )

    @setState({boxState: boxState})

  triggetRootEvent: (event)  ->
    events = [
      {
        path: [],
        event: event
      }
    ]
    @nextBoxState(events)

  triggerComponentEvent: (component, event)  ->
    events = [
      {
        path: component.path,
        event: event
      }
    ]
    @nextBoxState(events)

  onBatchButton: (event) ->
    @triggerComponentEvent(this.state.boxState.components.batch, { action: 'toggle' })

  onClickKey: (event, metaKeyId, contextKey) ->
    @triggerComponentEvent(this.state.boxState.components.batch, { action: 'select-key', metaKeyId: metaKeyId, contextKey: contextKey})

  onClickApplyAll: (event) ->
    events = [
      {
        path: [],
        event: {
          action: 'apply'
        }
      }
    ]
    @nextBoxState(events)

  onClickApplySelected: (event) ->
    events = [
      {
        path: [],
        event: {
          action: 'apply-selected'
        }
      }
    ]
    @nextBoxState(events)

  onClickCancel: (event) ->
    this.triggetRootEvent({action: 'cancel-all'})

  onClickIgnore: (event) ->
    this.triggetRootEvent({action: 'ignore-all'})

  getResources: () ->
    f.map(
      @state.boxState.components.resources,
      (r) => r.data.resource
    )

  getJsonPath: () ->

    if @props.get.json_path
      return @props.get.json_path

    path = parseUrl(@_currentUrl()).pathname
    if path.indexOf('/relations/children') > 0 or path.indexOf('/relations/siblings') > 0 or path.indexOf('/relations/parents') > 0
      return 'relation_resources.resources'

    if path.indexOf('/vocabulary') == 0 and path.indexOf('/content') > 0
      return 'resources.resources'

    if path.indexOf('/my/groups') == 0
      return 'resources.resources'

    if path.indexOf('/vocabulary/keyword') == 0
      return 'keyword.resources.resources'

    if path.indexOf('/people') == 0
      return 'resources.resources'


    if @props.get.type == 'MediaResources'
      if @props.get.config.for_url.pathname == @props.get.clipboard_url
        return 'resources'
      else
        return 'child_media_resources.resources'
    else if @props.get.type == 'MediaEntries'
      return 'resources'
    else if @props.get.type == 'Collections'
      return 'resources'


  requestId: Math.random()

  fetchListData: () ->
    this.triggetRootEvent({ action: 'fetch-list-data' })

  componentDidMount: ()->
    if @_mergeGet(@props, @state).config.layout == 'list'
      @fetchListData()

    # if f.includes(['MediaResources', 'MediaEntries', 'Collections'], @props.get.type)
    #   selection = Selection.createEmpty(() =>
    #     @setState(selectedResources: selection) if @isMounted()
    #   )

    @setState(
      isClient: true,
      # selectedResources: selection,
      config: resourceListParams(window.location)
    )

    this.triggetRootEvent({ action: 'mount' })


  forceFetchNextPage: () ->
    this.triggetRootEvent({ action: 'force-fetch-next-page' })

  # - custom actions:
  _onFetchNextPage: (event)->
    return if @state.boxState.data.loadingNextPage
    this.triggetRootEvent({ action: 'fetch-next-page' })

  _onFilterChange: (event, newParams)->
    event.preventDefault() if event && f.isFunction(event.preventDefault)

    # make sure that the new result starts on page 1
    newLocation = BoxSetUrlParams(@_currentUrl(), newParams, {list: {page: 1}})
    window.location = newLocation # SYNC!

  _onFilterToggle: (event, showFilter) ->

    return if isNewTab(event)

    event.preventDefault()
    href = getLocalLink(event)

    routerGoto(href)
    @setState({
      config: f.merge(@state.config, {show_filter: showFilter}),
      windowHref: href
    }, () =>
      @_persistListConfig(list_config: {show_filter: showFilter})
    )

  _onSearch: (event, refValues)->

    searchFilter = () =>
      if !@_supportsFilesearch() || refValues.searchTypeFulltextChecked
        {
          search: refValues.filterSearchValue
        }
      else
        {
          search: ''
        }

    filenameFilter = () =>
      if @_supportsFilesearch() && refValues.searchTypeFilenameChecked
        {
          media_files: [
            {
              key: 'filename',
              value: refValues.filterSearchValue
            }
          ]
        }
      else
        {}


    buildFilter = () ->
      f.merge(
        searchFilter(),
        filenameFilter()
      )

    @_onFilterChange(event,
      {
        list: {
          filter: buildFilter()
          accordion: {}
        }
      }
    )

  _onSideFilterChange: (event)->
    @_onFilterChange(event,
      {list: {
        filter: event.current
        accordion: event.accordion}})

  _selectionLimit: () ->
    256

  _onSelectResource: (resource, event)-> # toggles selection item
    event.preventDefault()
    selection = @state.boxState.data.selectedResources
    if !f.find(selection, (s) => s.uuid == resource.uuid) && selection.length > @_selectionLimit() - 1
      @_showSelectionLimit('single-selection')
    else
      this.triggetRootEvent({ action: 'toggle-resource-selection', resourceUuid: resource.uuid})

  handlePositionChange: (resourceId, direction, event) ->
    event.preventDefault()

    return if @state.boxState.data.loadingNextPage

    currentOrder = f.get(@state.config, 'order', @props.collectionData.order)

    targetOrder =
      if f.includes(['manual ASC', 'manual DESC'], currentOrder)
        currentOrder
      else
        'manual ASC'

    newConfig = f.extend({}, @state.config)
    prevOrder = newConfig.order

    newConfig.positionChange =
      prevOrder: prevOrder
      resourceId: resourceId
      direction: direction

    persistPosition = () =>
      simpleXhr(
        {
          method: 'PATCH',
          url: @props.collectionData.changePositionUrl,
          body: "positionChange=#{JSON.stringify(@state.config.positionChange)}"
        },
        (error) =>
          if error
            alert(error)
          else
            @_persistListConfig(list_config: {order: targetOrder})
            @forceFetchNextPage()
      )

    href = parseUrl(BoxSetUrlParams(@_currentUrl(), {list: {order: targetOrder}}))
    routerGoto(href)

    @setState(
      config: f.merge(newConfig, {order: targetOrder})#,
      windowHref: href
      ,
      persistPosition
    )

  _showSelectionLimit: (version) ->
    @setState(showSelectionLimit: version)

  _closeSelectionLimit: () ->
    @setState(showSelectionLimit: false)


  _onHoverMenu: (menu_id, event) ->
    @setState(hoverMenuId: menu_id)

  _currentUrl: () ->
    if @state.isClient && @state.windowHref
      # parseUrl(window.location.toString()).path
      @state.windowHref
    else
      BoxSetUrlParams(@props.get.config.for_url)

  _showBatchTransferResponsibility: (resources, event) ->
    @setState(
      showBatchTransferResponsibility: true,
      batchTransferResponsibilityResources: resources
    )

  _hideBatchTransferResponsibility: () ->
    @setState(
      showBatchTransferResponsibility: false,
      batchTransferResponsibilityResources: []
    )

  _sharedOnBatch: (resources, event, path) ->
    event.preventDefault()
    selected = f.map(resources, 'uuid')

    html = '<form method="post" acceptCharset="UTF-8" action="' + path + '">' +
      '<input type="hidden" name="authenticity_token" value="' + getRailsCSRFToken() + '"></input>' +
      '<input type="hidden" name="return_to" value="' + @_currentUrl() + '"></input>' +
      '<button type="button"></button>' +
      require('lodash').join(f.map(
        selected,
        (s) =>
          '<input type="hidden" name="id[]" value="' + s + '"></input>'
      ), '') +
      '</form>'

    form = $(html)
    document.body.appendChild(form[0])
    form.submit()

  _sharedOnBatchAll: (event, type) ->
    event.preventDefault()
    id = @props.collectionData.uuid
    path = '/sets/' + id + '/batch_edit_all'
    url = setUrlParams(path, {type: type, return_to: @_currentUrl()})
    window.location = url

  _persistListConfig: (config) ->
    req = appRequest(
      { method: 'PATCH', url: @_routeUrl('session_list_config'), json: config }
      , (err, res) -> if err then console.error(err))
    @doOnUnmount.push ()-> req.abort() if req && req.abort

  _onBatchEditAll: (event) ->
    @_sharedOnBatchAll(event, 'media_entry')

  _onBatchEdit: (resources, event) ->
    @_sharedOnBatch(resources, event, @_routeUrl('batch_edit_meta_data_by_context_media_entries'))

  _onBatchEditAllSets: (event) ->
    @_sharedOnBatchAll(event, 'collection')

  _onBatchEditSets: (resources, event) ->
    @_sharedOnBatch(resources, event, @_routeUrl('batch_edit_meta_data_by_context_collections'))

  _onBatchDeleteResources: (resources, event) ->
    event.preventDefault()
    @setState(
      batchDestroyResourcesModal: true,
      batchDestroyResourcesWaiting: false,
      batchDestroyResourcesError: false,
      batchDestroyResourceIdsWithTypes: resources.map (model) ->
        {
          uuid: model.uuid
          type: model.type
        }
      )
    return false

  _onExecuteBatchDeleteResources: () ->
    @setState(batchDestroyResourcesWaiting: true)
    resourceIds = @state.batchDestroyResourceIdsWithTypes
    url = setUrlParams(@_routeUrl('batch_destroy_resources'), {})
    railsFormPut.byData({resource_id: resourceIds}, url, (result) =>
      if result.result == 'error'
        window.scrollTo(0, 0)
        @setState(
          batchDestroyResourcesError: result.message
          batchDestroyResourcesWaiting: false
        )
      else
        location.reload()
    )
    return false




  _onBatchPermissionsEdit: (resources, event) ->
    @_sharedOnBatch(resources, event, @_routeUrl('batch_edit_permissions_media_entries'))

  _onBatchPermissionsSetsEdit: (resources, event) ->
    @_sharedOnBatch(resources, event, @_routeUrl('batch_edit_permissions_collections'))

  _onBatchTransferResponsibilityEdit: (resources, event) ->
    @_showBatchTransferResponsibility(resources, event)

  _onBatchTransferResponsibilitySetsEdit: (resources, event) ->
    @_showBatchTransferResponsibility(resources, event)

  _onBatchAddToSet: (resources, event)->
    event.preventDefault()
    @setState(batchAddToSet: true)
    return false

  _selectedResourceIdsWithTypes: () ->
    @state.boxState.data.selectedResources.map (model) ->
      {
        uuid: model.uuid
        type: model.type
      }

  _onBatchAddAllToClipboard: (event) ->
    event.preventDefault()
    @setState(clipboardModal: 'add_all')

  _onBatchAddSelectedToClipboard: (resources, event) ->
    event.preventDefault()
    @setState(clipboardModal: 'add_selected')

  _onBatchRemoveAllFromClipboard: (event) ->
    event.preventDefault()
    @setState(clipboardModal: 'remove_all')

  _onBatchRemoveFromClipboard: (resources, event) ->
    event.preventDefault()
    @setState(clipboardModal: 'remove_selected')

  _onBatchRemoveFromSet: (resources, event)->
    event.preventDefault()
    @setState(batchRemoveFromSet: true)
    return false

  _onCloseModal: () ->
    @setState(clipboardModal: 'hidden')
    @setState(batchAddToSet: false)
    @setState(batchRemoveFromSet: false)
    @setState(batchDestroyResourcesModal: false)

  setLayout: (layoutMode)=> # NOTE: this is a hack and goes around the router :/
    unless f.includes(f.map(BoxUtil.allowedLayoutModes(@props.disableListMode), 'mode'), layoutMode)
      throw new Error "Invalid Layout!"
    @setState(config: f.merge(@state.config, {layout: layoutMode}))

  _mergeGet: (props, state) ->
    f.extend(
      props.get,
      {
        config: defaultsDeep(
          {},
          state.config,
          props.get.config,
          props.initial,
          {
            layout: state.savedLayout
            order: state.savedOrder
          },
          props.get.config.user,
          {
            layout: 'grid'
            order: 'last_change DESC'
            show_filter: false
          }
        )
      }
    )


  _supportsFilesearch: () ->
    get = @props.get
    !get.disable_file_search && !(
      get.config && get.config.for_url && get.config.for_url.query.type == 'collections'
    )

  _routeUrl: (name) ->
    @props.get.route_urls[name]

  _resetFilterLink: (config) ->
    resetFilterHref =
      BoxSetUrlParams(@_currentUrl(), {list: {page: 1, filter: {}, accordion: {}}})

    if resetFilterHref
      if f.present(config.filter) or f.present(config.accordion)
        <Link mods='mlx weak' href={resetFilterHref}>
          <Icon i='undo'/> {t('resources_box_reset_filter')}</Link>


  unselectResources: (resources) ->
    this.triggetRootEvent({ action: 'unselect-resources', resourceUuids: f.map(resources, (r) => r.uuid)})


  selectResources: (resources) ->
    this.triggetRootEvent({ action: 'select-resources', resourceUuids: f.map(resources, (r) => r.uuid)})


  onSortItemClick: (event, itemKey) ->

    return if isNewTab(event)

    event.preventDefault()

    href = getLocalLink(event)
    routerGoto(href)

    @setState(
      config: f.merge(@state.config, {order: itemKey}),
      windowHref: href
      ,
      () =>
        # @state.resources.clearPages({
        #   pathname: url.pathname,
        #   query: url.query
        # })

        this.forceFetchNextPage()
        @_persistListConfig(list_config: {order: itemKey})
    )

  onLayoutClick: (event, layoutMode) ->
    return if isNewTab(event)
    event.preventDefault()
    href = getLocalLink(event)
    routerGoto(href)
    @setState(
      config: f.merge(@state.config, {layout: layoutMode.mode}),
      windowHref: href
      ,
      () =>
        if layoutMode.mode == 'list'
          @fetchListData()
        @_persistListConfig(list_config: {layout: layoutMode.mode})
    )

  layoutSave: (event) ->
    event.preventDefault()
    config = @_mergeGet(@props, @state).config
    layout = config.layout
    order = config.order
    contextId = f.get(@props, 'collectionData.contextId')
    typeFilter = f.get(@props, 'collectionData.typeFilter')

    requestBody = []
    requestBody.push('collection[layout]=' + layout)
    requestBody.push('collection[sorting]=' + order)
    requestBody.push('collection[default_context_id]=' + contextId) if contextId
    requestBody.push('collection[default_resource_type]=' + typeFilter)

    simpleXhr(
      {
        method: 'PATCH',
        url: @props.collectionData.url,
        body: requestBody.join('&')
      },
      (error) =>
        if error
          alert(error)
        else
          @setState(savedLayout: layout, savedOrder: order, savedContextId: contextId, savedResourceType: typeFilter)
    )
    return false

  render: ()->
    {
      get, mods, initial, fallback, heading, listMods
      saveable, authToken, children
    } = @props

    get = @_mergeGet(@props, @state)

    resources = @getResources()

    config = get.config

    currentQuery = f.merge(
      {list: f.merge f.omit(config, 'for_url', 'user')},
      {
        list: filter: config.filter,
        accordion: config.accordion
      })
    currentUrl = @_currentUrl()

    boxTitleBar = () =>
      {filter, layout, for_url, order} = config
      totalCount = f.get(get, 'pagination.total_count')
      isClient = @state.isClient

      layouts = BoxUtil.allowedLayoutModes(@props.disableListMode).map (layoutMode) =>
        href = BoxSetUrlParams(currentUrl, {list: {layout: layoutMode.mode}})
        f.merge layoutMode,
          mods: {'active': layoutMode.mode == layout}
          href: href


      BoxTitlebar = require('./BoxTitlebar.jsx')
      <BoxTitlebar
        actionName={@props.actionName}
        enableOrderByTitle={@props.enableOrderByTitle}
        layout={layout}
        order={order}
        savedLayout={@state.savedLayout}
        savedOrder={@state.savedOrder}
        savedContextId={@state.savedContextId}
        savedResourceType={@state.savedResourceType}
        defaultTypeFilter={@props.collectionData?.defaultTypeFilter}
        layoutSave={@layoutSave}
        collectionData={@props.collectionData}
        heading={heading}
        totalCount={totalCount}
        mods={mods}
        layouts={layouts}
        onSortItemClick={@onSortItemClick}
        selectedSort={order}
        enableOrdering={@props.enableOrdering}
        enableOrderByManual={@props.enableOrderByManual}
        currentUrl={currentUrl}
        onLayoutClick={@onLayoutClick}
      />


    actionsDropdownParameters = {
      totalCount: @props.get.pagination.total_count if @props.get.pagination
      withActions: get.has_user
      selection: @state.boxState.data.selectedResources or false
      saveable: (saveable or false)
      draftsView: @props.draftsView
      isClient: @state.isClient
      collectionData: @props.collectionData
      config: config
      featureToggles: get.feature_toggles
      isClipboard: if @props.initial then @props.initial.is_clipboard else false
      content_type: @props.get.content_type
      showAddSetButton: f.get(@props, 'showAddSetButton', false)
    }


    boxToolBar = () =>

      actionsDropdown = <ActionsDropdown
        parameters={actionsDropdownParameters}
        callbacks={{
          onBatchAddAllToClipboard: @_onBatchAddAllToClipboard
          onBatchAddSelectedToClipboard: @_onBatchAddSelectedToClipboard
          onBatchRemoveAllFromClipboard: @_onBatchRemoveAllFromClipboard
          onBatchRemoveFromClipboard: @_onBatchRemoveFromClipboard
          onBatchAddToSet: @_onBatchAddToSet
          onBatchRemoveFromSet: @_onBatchRemoveFromSet
          onBatchEditAll: @_onBatchEditAll
          onBatchEdit: @_onBatchEdit
          onBatchEditAllSets: @_onBatchEditAllSets
          onBatchEditSets: @_onBatchEditSets
          onBatchDeleteResources: @_onBatchDeleteResources
          onBatchPermissionsEdit: @_onBatchPermissionsEdit
          onBatchPermissionsSetsEdit: @_onBatchPermissionsSetsEdit
          onBatchTransferResponsibilityEdit: @_onBatchTransferResponsibilityEdit
          onBatchTransferResponsibilitySetsEdit: @_onBatchTransferResponsibilitySetsEdit
          onHoverMenu: @_onHoverMenu
          onQuickBatch: @onBatchButton
          onShowCreateCollectionModal: () => @setState(showCreateCollectionModal: true)
        }}
      />

      filterToggleLink = BoxSetUrlParams(
        currentUrl, {list: {show_filter: (not config.show_filter)}})

      filterBarProps =
        left: <BoxFilterButton
          get={get}
          config={config}
          _onFilterToggle={@_onFilterToggle}
          filterToggleLink={filterToggleLink}
          resetFilterLink={if f.present(config.filter) then @_resetFilterLink(config)}
        />

        right: if actionsDropdown
          <div>{actionsDropdown}</div>


        middle: if @props.resourceTypeSwitcherConfig
          if @props.resourceTypeSwitcherConfig.customRenderer
            @props.resourceTypeSwitcherConfig.customRenderer(currentUrl)
          else
            resourceTypeSwitcher(currentUrl, @props.collectionData?.defaultTypeFilter, @props.resourceTypeSwitcherConfig.showAll, null)

      <BoxToolBar {...filterBarProps}/>

    sidebar = do ({config, dynamic_filters} = get, {isClient} = @state)=>
      return null if not config.show_filter
      BoxSidebar = require('./BoxSidebar.jsx')
      <BoxSidebar
        config={config}
        dynamic_filters={dynamic_filters}
        isClient={isClient}
        currentQuery={currentQuery}
        currentUrl={@_currentUrl()}
        onSearch={@_onSearch}
        supportsFilesearch={@_supportsFilesearch()}
        onlyFilterSearch={get.only_filter_search}
        parentState={@state}
        onSideFilterChange={@_onSideFilterChange}
        jsonPath={@getJsonPath()}
      />


    paginationNav = (resources, staticPagination) =>

      BoxPaginationNav = require('./BoxPaginationNav.jsx')
      <BoxPaginationNav
        resources={resources}
        staticPagination={staticPagination}
        onFetchNextPage={@_onFetchNextPage}
        loadingNextPage={@state.boxState.data.loadingNextPage}
        isClient={@state.isClient}
        permaLink={BoxSetUrlParams(@_currentUrl(), currentQuery)}
        currentUrl={currentUrl}
        perPage={@props.get.config.per_page}
      />


    # component:
    <div data-test-id='resources-box' className={BoxUtil.boxClasses(mods)}>
      {
        if @state.showBatchTransferResponsibility
          actionUrls = {
            MediaEntry: @_routeUrl('batch_update_transfer_responsibility_media_entries')
            Collection: @_routeUrl('batch_update_transfer_responsibility_collections')
          }
          BoxTransfer = require('./BoxTransfer.jsx')
          <BoxTransfer
            authToken={@props.authToken}
            transferResources={@state.batchTransferResponsibilityResources}
            onClose={@_hideBatchTransferResponsibility}
            onSaved={() -> location.reload()}
            actionUrls={actionUrls}
            currentUser={@props.get.current_user}
          />
      }

      {
        if @state.showSelectionLimit
          BoxSelectionLimit = require('./BoxSelectionLimit.jsx')
          <BoxSelectionLimit
            showSelectionLimit={@state.showSelectionLimit}
            selectionLimit={@_selectionLimit()}
            onClose={@_closeSelectionLimit}
          />
      }

      {boxTitleBar()}

      {if get.info_header
        <div className="mam">
          <InfoHeader {...get.info_header} />
        </div>
      }

      {boxToolBar()}

      { if @state.showCreateCollectionModal
        <CreateCollectionModal
          get={get.new_collection}
          async={false}
          authToken={authToken}
          onClose={() => @setState(showCreateCollectionModal: false)}
          newCollectionUrl={f.get(@props, 'collectionData.newCollectionUrl')} />}

      <div className='ui-resources-holder pam'>
        <div className='ui-container table auto'>
          {sidebar}

          {# main list:}
          <div className='ui-container table-cell table-substance'>
            {children}

            <BoxBatchEditForm
              onClose={(e) => @onBatchButton(e)}
              stateBox={@state.boxState}
              onClickKey={(e, k, ck) => @onClickKey(e, k, ck)}
              onClickApplyAll={(e) => @onClickApplyAll(e)}
              onClickApplySelected={(e) => @onClickApplySelected(e)}
              onClickCancel={(e) => @onClickCancel(e)}
              onClickIgnore={(e) => @onClickIgnore(e)}
              totalCount={@props.get.pagination.total_count}
              allLoaded={@props.get.pagination && @state.boxState.components.resources.length == @props.get.pagination.total_count}
              trigger={@triggerComponentEvent}
            />


            {if resources.length == 0 && @state.boxState.data.loadingNextPage
              <Preloader />
            else if not f.present(resources) or resources.length == 0 then do () =>
              BoxSetFallback = require('./BoxSetFallback.jsx')
              <BoxSetFallback
                fallback={fallback}
                try_collections={get.try_collections}
                currentUrl={@_currentUrl()}
                usePathUrlReplacement={@props.usePathUrlReplacement}
                resetFilterLink={@_resetFilterLink(config)}
              />
            else
              BoxRenderResources = require('./BoxRenderResources.jsx')
              positionProps =
                handlePositionChange: @handlePositionChange
                changeable: f.get(@props, 'collectionData.position_changeable', false)
                disabled: @state.boxState.data.loadingNextPage

              <BoxRenderResources
                resources={
                  f.map(
                    @state.boxState.components.resources,
                    (r) => r
                  )
                }
                applyJob={@state.boxState.components.batch.data.applyJob}
                actionsDropdownParameters={actionsDropdownParameters}
                selectedResources={@state.boxState.data.selectedResources}
                isClient={@state.isClient}
                showSelectionLimit={@_showSelectionLimit}
                selectionLimit={@_selectionLimit()}
                onSelectResource={@_onSelectResource}
                positionProps={positionProps}
                config={config}
                hoverMenuId={@state.hoverMenuId}
                authToken={authToken}
                withActions={get.has_user}
                listMods={listMods}
                pagination={@props.get.pagination}
                perPage={@props.get.config.per_page}
                showBatchButtons={
                  {
                    editMode: @state.boxState.components.batch.data.open && @state.boxState.components.batch.components.metaKeyForms.length > 0
                  }
                }
                unselectResources={@unselectResources}
                selectResources={@selectResources}
                trigger={@triggerComponentEvent}
                selectionMode={@state.boxState.components.batch.data.open}
              />

            }
            {paginationNav(resources, get.pagination)}
          </div>

        </div>
      </div>

      {
        if @state.clipboardModal != 'hidden'
          <Clipboard type={@state.clipboardModal}
            onClose={() => @setState(clipboardModal: 'hidden')}
            resources={@getResources()}
            selectedResources={@state.boxState.data.selectedResources}
            pagination={@props.get.pagination}
            forUrl={@props.for_url}
            jsonPath={@getJsonPath()}
          />
      }
      {
        if @state.batchAddToSet
          <BatchAddToSetModal resourceIds={@_selectedResourceIdsWithTypes()} authToken={@props.authToken}
            get={null} onClose={@_onCloseModal} returnTo={currentUrl} />
      }
      {
        if @state.batchRemoveFromSet
          <BatchRemoveFromSetModal collectionUuid={@props.collectionData.uuid}
            resourceIds={@_selectedResourceIdsWithTypes()} authToken={@props.authToken}
            get={null} onClose={@_onCloseModal} returnTo={currentUrl} />
      }
      {
        if @state.batchDestroyResourcesModal
          BoxDestroy = require('./BoxDestroy.jsx')
          <BoxDestroy
            loading={@state.batchDestroyResourcesWaiting}
            error={@state.batchDestroyResourcesError}
            idsWithTypes={@state.batchDestroyResourceIdsWithTypes}
            onClose={@_onCloseModal}
            onOk={@_onExecuteBatchDeleteResources}
          />
      }

    </div>

# export helper
module.exports.boxSetUrlParams = BoxSetUrlParams
