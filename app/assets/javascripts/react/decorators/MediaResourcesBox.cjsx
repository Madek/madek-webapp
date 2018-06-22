React = require('react')
f = require('active-lodash')
defaultsDeep = require('lodash/defaultsDeep')
fromPairs = require('lodash/fromPairs')
ampersandReactMixin = require('ampersand-react-mixin')
ui = require('../lib/ui.coffee')
{parseMods, cx} = ui
t = ui.t
setUrlParams = require('../../lib/set-params-for-url.coffee')
parseUrl = require('url').parse
stringifyUrl = require('url').format
parseQuery = require('qs').parse
Selection = require('../../lib/selection.coffee')
resourceListParams = require('../../shared/resource_list_params.coffee')
appRequest = require('../../lib/app-request.coffee')

Waypoint = require('react-waypoint')
RailsForm = require('../lib/forms/rails-form.cjsx')
ResourceThumbnail = require('./ResourceThumbnail.cjsx')
{ Button, ButtonGroup, Icon, Link, Preloader, Dropdown, ActionsBar
} = require('../ui-components/index.coffee')
MenuItem = Dropdown.MenuItem
SideFilter = require('../ui-components/ResourcesBox/SideFilter.cjsx')
BoxToolBar = require('../ui-components/ResourcesBox/BoxToolBar.cjsx')

Modal = require('../ui-components/Modal.cjsx')
EditTransferResponsibility = require('../views/Shared/EditTransferResponsibility.cjsx')

# models
MediaEntries = require('../../models/media-entries.coffee')
Collections = require('../../models/collections.coffee')
CollectionChildren = require('../../models/collection-children.coffee')

# interactive stuff, should be moved to controller
router = null # client-side only
xhr = require('xhr')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
BatchAddToSetModal = require('./BatchAddToSetModal.cjsx')
BatchRemoveFromSetModal = require('./BatchRemoveFromSetModal.cjsx')

simpleXhr = require('../../lib/simple-xhr.coffee')

LoadXhr = require('../../lib/load-xhr.coffee')
Preloader = require('../ui-components/Preloader.cjsx')

SortDropdown = require('./resourcesbox/SortDropdown.cjsx')
ActionsDropdown = require('./resourcesbox/ActionsDropdown.cjsx')
Clipboard = require('./resourcesbox/Clipboard.cjsx')

railsFormPut = require('../../lib/form-put-with-errors.coffee')

setsFallbackUrl = require('../../lib/sets-fallback-url.coffee')
libUrl = require('url')
qs = require('qs')

BoxUtil = require('./BoxUtil.js')

BoxSetUrlParams = require('./BoxSetUrlParams.jsx')

# Props/Config overview:
# - props.get.has_user = should the UI offer any interaction
# - state.isClient = is component in client-side mode
# - props.get.can_filter = is it possible to filter the resources
# - props.get.filter = the currently active filter
# - props.get.config.show_filter = if the filterBar should be shown

# TODO: i18n


getLocalLink = (event) ->
  localLinks = require('local-links')
  return localLinks.pathname(event)



isNewTab = (event) ->
  localLinks = require('local-links')
  if (internalLink = localLinks.pathname(event))
    return false
  else
    return true


# only handle *local* link events (not opening in new tab, etc):
handleIfNotNewTabAndAddressChanged = (event, callback)->
  localLinks = require('local-links')
  if (internalLink = localLinks.pathname(event))
    event.preventDefault()
    if not localLinks.isActive(event)
      callback(event)


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
    listMetadata: {}
    loadingListMetadataResource: null
    loadingNextPage: false
    modelReloading: false
    showBatchTransferResponsibility: false
    batchTransferResponsibilityResources: []
    batchDestroyResourcesModal: false
    batchDestroyResourcesWaiting: false
    showSelectionLimit: false
  }

  doOnUnmount: [] # to be filled with functions to be called on unmount
  componentWillUnmount: ()->
    f.each(f.compact(@doOnUnmount), (fn)->
      if f.isFunction(fn) then fn() else console.error("Not a Function!", fn))

  _createResourcesModel: (get) ->
    collectionClass = switch get.type
      when 'MediaResources' then CollectionChildren
      when 'MediaEntries' then MediaEntries
      when 'Collections' then Collections

    if collectionClass
      if f.present(f.get(get, 'pagination.total_count'))
        if !collectionClass.Paginated then throw new Error('Collection has no Pagination!')

        # HACK
        if get.config.for_url.pathname == get.clipboard_url
          (new collectionClass.PaginatedClipboard(get))
        else
          (new collectionClass.Paginated(get))
      else
        (new collectionClass(get.resources))


  componentWillMount: ()->
    resources = if f.get(@props, 'get.resources.isCollection')
      throw new Error('is collection') # should not be the case anymore after uploader is not using this box anymore
    else
      @_createResourcesModel(@props.get)
    @setState(resources: resources)

  componentDidMount: ()->
    if @state.resources.fetchListData && @_mergeGet(@props, @state).config.layout == 'list'
      @state.resources.fetchListData()

    router = if @props.router # NOTE: not a default prop so we know if we have to start()
      @props.router
    else
      require('../../lib/router.coffee')

    # listen to history and set state from params:
    unlistenFn = router.listen (location)=>
      @setState(config: f.merge(@state.config, resourceListParams(location)))
    # TMP: start the router if we set it up here:
    # (also immediatly calls listener(s) once if already attached!)
    @doOnUnmount.push(unlistenFn)
    router.start() unless @props.router

    if f.includes(['MediaResources', 'MediaEntries', 'Collections'], @props.get.type)
      selection = Selection.createEmpty(() =>
        @setState(selectedResources: selection) if @isMounted()
      )

    if @state.resources
      @fetchNextPage = f.throttle(
        ((c) =>
          @state.resources.fetchNext(@_mergeGet(@props, @state).config.layout == 'list', c)
        )
      , 1000)
      @doOnUnmount.push(@fetchNextPage.cancel())
    @setState(isClient: true, router: router, selectedResources: selection)

  # client-side link handlers:
  # - for state changes that don't need new data (like visual changes):
  setAddressByEventHrefAndUpdateState: (event) ->
    localLinks = require('local-links')
    href = localLinks.pathname(event)
    cfg = f.pick(parseQuery(parseUrl(href).query).list, ['layout', 'order', 'show_filter'])
    if cfg then @_persistListConfig(list_config: cfg) # async, but fire-and-forget
    router.goTo(href)

  # # - for state changes that update the resources (like filter):
  # _handleRequestInternally: (event)->
  #   handleIfNotNewTabAndAddressChanged(event, alert)

  # - custom actions:
  _onFetchNextPage: (event)->
    return if @state.loadingNextPage
    @setState(loadingNextPage: true)
    @fetchNextPage (err, newUrl)=>
      if err then console.error(err)
      @setState(loadingNextPage: false) if @isMounted()

  _onFilterChange: (event, newParams)->
    event.preventDefault() if event && f.isFunction(event.preventDefault)

    # make sure that the new result starts on page 1
    newLocation = BoxSetUrlParams(@_currentUrl(), newParams, {list: {page: 1}})
    window.location = newLocation # SYNC!

  _onFilterToggle: (event, showFilter) ->

    return if isNewTab(event)

    event.preventDefault()
    href = getLocalLink(event)

    @setState({
      config: f.merge(@state.config, {show_filter: showFilter})
    }, () =>
      @_persistListConfig(list_config: {show_filter: showFilter})
      router.goTo(href)
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
    36

  _onSelectResource: (resource, event)-> # toggles selection item
    event.preventDefault()
    selection = @state.selectedResources
    if !selection.contains(resource.serialize()) && selection.length() > @_selectionLimit() - 1
      @_showSelectionLimit('single-selection')
    else
      selection.toggle(resource.serialize())

  _showSelectionLimit: (version) ->
    @setState(showSelectionLimit: version)

  _closeSelectionLimit: () ->
    @setState(showSelectionLimit: false)


  _onSelectionAllToggle: (event)-> # toggles selection
    event.preventDefault()
    @state.selectedResources.toggleAll(@state.resources.serialize().resources)

  _onHoverMenu: (menu_id, event) ->
    @setState(hoverMenuId: menu_id)

  _currentUrl: () ->
    if router
      parseUrl(window.location.toString()).path
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
    batchEditUrl = setUrlParams(path, {id: selected, return_to: @_currentUrl()})
    window.location = batchEditUrl # SYNC!

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
    @state.selectedResources.selection.map (model) ->
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
    # TODO: refactor this + currentQuery into @getInitialState + @getCurrentQuery
    get = defaultsDeep \      # combine config in order:
      {},
      {config: state.config},  # - client-side state
      props.get,                      # - presenter & config (from params)
      {config: props.initial},        # - per-view initial default config
      config:                   # - config saved for set
        layout: state.savedLayout
        order: state.savedOrder
      ,
      {config: props.get.config.user}
      ,
      config:                   # - default config
        layout: 'grid'
        order: 'last_change'
        show_filter: false

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


  render: ()->
    {
      get, mods, initial, fallback, heading, listMods
      saveable, authToken, children
    } = @props

    get = @_mergeGet(@props, @state)

    # FIXME: always get from state!
    resources = @state.resources || get.resources

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
          onClick: (event) =>
            @state.resources.fetchListData() if layoutMode.mode == 'list'
            handleIfNotNewTabAndAddressChanged(event, (e) => @setAddressByEventHrefAndUpdateState(e))

      onSortItemClick = (event, itemKey) =>

        return if isNewTab(event)

        event.preventDefault()
        @fetchNextPage.cancel()

        href = getLocalLink(event)

        @setState(
          config: f.merge(@state.config, {order: itemKey})
          ,
          () =>
            url = parseUrl(BoxSetUrlParams(@_currentUrl(), {list: {order: itemKey}}))
            @state.resources.clearPages({
              pathname: url.pathname,
              query: url.query
            })
            @setState(loadingNextPage: true)
            @fetchNextPage (err, newUrl) =>
              if err then console.error(err)
              @setState(loadingNextPage: false) if @isMounted()

            @_persistListConfig(list_config: {order: itemKey})
            router.goTo(href)

        )



      layoutSave = (event) =>
        event.preventDefault()
        simpleXhr(
          {
            method: 'PATCH',
            url: @props.collectionData.url,
            body: 'collection[layout]=' + layout + '\&collection[sorting]=' + order
          },
          (error) =>
            if error
              alert(error)
            else
              @setState(savedLayout: layout, savedOrder: order)
        )
        return false

      BoxTitlebar = require('./BoxTitlebar.jsx')
      <BoxTitlebar
        enableOrderByTitle={@props.enableOrderByTitle}
        layout={layout}
        order={order}
        savedLayout={@state.savedLayout}
        savedOrder={@state.savedOrder}
        layoutSave={layoutSave}
        collectionData={@props.collectionData}
        heading={heading}
        totalCount={totalCount}
        mods={mods}
        layouts={layouts}
        onSortItemClick={onSortItemClick}
        selectedSort={order}
        enableOrdering={@props.enableOrdering}
        currentUrl={currentUrl}
      />


    actionsDropdownParameters = {
      totalCount: @props.get.pagination.total_count if @props.get.pagination
      withActions: get.has_user
      selection: f.presence(@state.selectedResources) or false
      saveable: (saveable or false)
      draftsView: @props.draftsView
      isClient: @state.isClient
      collectionData: @props.collectionData
      config: config
      isClipboard: if @props.initial then @props.initial.is_clipboard else false
      content_type: @props.get.content_type
    }


    boxToolBar = () =>

      actionsDropdown = ActionsDropdown.createActionsDropdown(
        actionsDropdownParameters,
        {
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
        })



      filterToggleLink = BoxSetUrlParams(
        currentUrl, {list: {show_filter: (not config.show_filter)}})

      not_is_clipboard = true # !@props.initial || !@props.initial.is_clipboard
      filterBarProps =
        left: if get.can_filter && not_is_clipboard then do =>
          name = t('resources_box_filter')
          <div>
            <Button data-test-id='filter-button' name={name} mods={'active': config.show_filter}
              href={filterToggleLink} onClick={(e) => @_onFilterToggle(e, not config.show_filter)}>
              <Icon i='filter' mods='small'/> {name}
            </Button>
            {if f.present(config.filter) then @_resetFilterLink(config)}
          </div>

        right: if actionsDropdown
          <div>{actionsDropdown}</div>


        middle: @props.toolBarMiddle

      <BoxToolBar {...filterBarProps}/>

    sidebar = do ({config, dynamic_filters} = get, {isClient} = @state)=>
      return null if not config.show_filter
      BoxSidebar = require('./BoxSidebar.jsx')
      <BoxSidebar
        config={config}
        dynamic_filters={dynamic_filters}
        isClient={isClient}
        currentQuery={currentQuery}
        onSearch={@_onSearch}
        supportsFilesearch={@_supportsFilesearch()}
        onlyFilterSearch={get.only_filter_search}
        parentState={@state}
        onSideFilterChange={@_onSideFilterChange}
      />


    paginationNav = (resources, staticPagination) =>

      BoxPaginationNav = require('./BoxPaginationNav.jsx')
      <BoxPaginationNav
        resources={resources}
        staticPagination={staticPagination}
        onFetchNextPage={@_onFetchNextPage}
        loadingNextPage={@state.loadingNextPage}
        isClient={@state.isClient}
        permaLink={BoxSetUrlParams(@_currentUrl(), currentQuery)}
        currentUrl={currentUrl}
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
      {boxToolBar()}

      <div className='ui-resources-holder pam'>
        <div className='ui-container table auto'>
          {sidebar}

          {# main list:}
          <div className='ui-container table-cell table-substance'>
            {children}
            {if resources.currentPage == 0
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
              <BoxRenderResources
                resources={resources}
                actionsDropdownParameters={actionsDropdownParameters}
                selectedResources={@state.selectedResources}
                isClient={@state.isClient}
                showSelectionLimit={@_showSelectionLimit}
                selectionLimit={@_selectionLimit()}
                onSelectResource={@_onSelectResource}
                config={config}
                hoverMenuId={@state.hoverMenuId}
                authToken={authToken}
                withActions={get.has_user}
                listMods={listMods}
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
            resources={@state.resources}
            selectedResources={@state.selectedResources} />
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
