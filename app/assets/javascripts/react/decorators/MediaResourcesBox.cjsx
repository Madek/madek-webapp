React = require('react')
f = require('active-lodash')
fromPairs = require('lodash/fromPairs')
ampersandReactMixin = require('ampersand-react-mixin')
ui = require('../lib/ui.coffee')
{parseMods, cx} = ui
t = ui.t('de')
setUrlParams = require('../../lib/set-params-for-url.coffee')
parseUrl = require('url').parse
stringifyUrl = require('url').format
Selection = require('../../lib/selection.coffee')
resourceListParams = require('../../shared/resource_list_params.coffee')

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
qs = require('qs')
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

# Props/Config overview:
# - props.get.with_actions = should the UI offer any interaction
# - props.fetchRelations = should relations be fetched (async, only grid layout)
# - props.withBox = should the grid be wrapped in a Box… [TMP!]
# - state.isClient = is component in client-side mode
# - props.get.can_filter = is it possible to filter the resources
# - props.get.filter = the currently active filter
# - props.get.config.show_filter = if the filterBar should be shown

# TODO: i18n

# only handle *local* link events (not opening in new tab, etc):
handleLinkIfLocal = (event, callback)->
  localLinks = require('local-links')
  if (internalLink = localLinks.pathname(event))
    event.preventDefault()
    callback(internalLink) if not localLinks.isActive(event)

filterConfigProps = React.PropTypes.shape
  search: React.PropTypes.string
  meta_data: React.PropTypes.arrayOf React.PropTypes.shape
    key: React.PropTypes.string.isRequired
    match: React.PropTypes.string
    value: React.PropTypes.string
    type: React.PropTypes.string # must be sub-type of MetaDatum
  media_file: React.PropTypes.arrayOf React.PropTypes.shape
    key: React.PropTypes.string.isRequired
    value: React.PropTypes.string
  permissions: React.PropTypes.arrayOf React.PropTypes.shape
    key: React.PropTypes.string.isRequired
    value: React.PropTypes.oneOfType([React.PropTypes.string, React.PropTypes.bool])

# view Config - bound to the URL (params)!
viewConfigProps = React.PropTypes.shape
  show_filter: React.PropTypes.bool
  filter: filterConfigProps
  layout: React.PropTypes.oneOf(['tiles', 'miniature', 'grid', 'list'])
  pagination: React.PropTypes.shape
    prev: React.PropTypes.shape(page: React.PropTypes.number.isRequired)
    next: React.PropTypes.shape(page: React.PropTypes.number.isRequired)
  for_url: React.PropTypes.shape
    pathname: React.PropTypes.string.isRequired
    query: React.PropTypes.object

# url helper that deals with our weird parameter serialisation
boxSetUrlParams = (url, params...) ->
  params = params.map((param) ->
    fromPairs(f.map(param, (val, key) ->
      if (key == 'list')
        return [
          key,
          fromPairs(f.compact(f.map(val, (v, k) ->
            if (f.includes(['accordion', 'filter'], k))
              return if v == null
              return [k, if typeof v == 'object' then JSON.stringify(v) else v]
            [k, v])))
        ]
      [key, val]
    )))
  setUrlParams(url, params...)

module.exports = React.createClass
  displayName: 'MediaResourcesBox'
  propTypes:
    initial: viewConfigProps
    withBox: React.PropTypes.bool # toggles simple grid or full box
    fetchRelations: React.PropTypes.bool
    fallback: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.node])
    heading: React.PropTypes.node
    toolBarMiddle: React.PropTypes.node
    authToken: React.PropTypes.string.isRequired
    disablePermissionsEdit: React.PropTypes.bool
    allowListMode: React.PropTypes.bool
    get: React.PropTypes.shape
      # resources: React.PropTypes.array # TODO: array of ampersandCollection
      type: React.PropTypes.oneOf([
        'MediaEntries', 'Collections', 'FilterSets', 'MediaResources'])
      with_actions: React.PropTypes.bool # toggles actions, hover, flyout
      can_filter: React.PropTypes.bool # if true, get.resources can be filtered
      config: viewConfigProps # <- config that is part of the URL!
      dynamic_filters: React.PropTypes.array

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
  }

  _allowedLayoutModes: () ->
    [
      {mode: 'tiles', title: 'Kachel-Ansicht', icon: 'vis-pins'}
      {mode: 'grid', title: 'Raster-Ansicht', icon: 'vis-grid'}
    ].concat(
      if @props.allowListMode then [
        {mode: 'list', title: 'Listen-Ansicht', icon: 'vis-list'}
      ] else []
    ).concat(
      {mode: 'miniature', title: 'Miniatur-Ansicht', icon: 'vis-miniature'}
    )

  doOnUnmount: [] # to be filled with functions to be called on unmount
  componentWillUnmount: ()->
    f.each(f.compact(@doOnUnmount), (fn)->
      if f.isFunction(fn) then fn() else console.error("Not a Function!", fn))

  _createResourcesModel: (get, withBox) ->
    collectionClass = switch get.type
      when 'MediaResources' then CollectionChildren
      when 'MediaEntries' then MediaEntries
      when 'Collections' then Collections

    if collectionClass
      if withBox && f.present(f.get(get, 'pagination.total_count'))
        if !collectionClass.Paginated then throw new Error('Collection has no Pagination!')

        # HACK
        if get.config.for_url.pathname == '/my/clipboard'
          (new collectionClass.PaginatedClipboard(get))
        else
          (new collectionClass.Paginated(get))
      else
        (new collectionClass(get.resources))


  _tryLoadListMetadata: (resource) ->
    {type, uuid, url} = resource
    if not @state.loadingListMetadataResource
      @setState({loadingListMetadataResource: uuid})
      LoadXhr({
        method: 'GET',
        url:
          if type == 'Collection'
            url + '.json?___sparse={"meta_data":{}}'
          else if type == 'MediaEntry'
            url + '.json?___sparse={"meta_data":{}}'
          else
            console.error('Unknown resource type for loading meta data: ' + resourceType)

      },
      (result, json) =>
        @setState({
          loadingListMetadataResource: null,
          listMetadata: f.assign(@state.listMetadata, f.set({}, uuid, json.meta_data))
        })
      )


  componentWillMount: ()->
    resources = if f.get(@props, 'get.resources.isCollection')
      @props.get.resources # if already initialized just use that
    else
      @_createResourcesModel(@props.get, @props.withBox)
    @setState(resources: resources)

  componentDidMount: ()->
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

    if ['MediaResources', 'MediaEntries', 'Collections'].includes(@props.get.type)
      selection = Selection.createEmpty(() =>
        @setState(selectedResources: selection) if @isMounted()
      )

    if @state.resources
      @fetchNextPage = f.throttle(((c)=> @state.resources.fetchNext(c)), 1000)
      @doOnUnmount.push(@fetchNextPage.cancel())
    @setState(isClient: true, router: router, selectedResources: selection)

  # client-side link handlers:
  # - for state changes that don't need new data (like visual changes):
  _handleChangeInternally: (event) ->
    handleLinkIfLocal(
      event,
      (href) ->
        router.goTo(href)
    )

  # # - for state changes that update the resources (like filter):
  # _handleRequestInternally: (event)->
  #   handleLinkIfLocal(event, alert)

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
    newLocation = boxSetUrlParams(@_currentUrl(), newParams, {list: {page: 1}})
    window.location = newLocation # SYNC!

  _onFilterToggle: (event)->
    # NOTE: if dynfilters are loaded, just open/close sidebar in client
    if f.present(f.get(@props, ['get', 'dynamic_filters']))
      event.preventDefault()
      @_handleChangeInternally(event)
    return undefined

  _onSearch: (event)->
    @_onFilterChange(event,
      {
        list: {
          filter: {search: @refs.filterSearch.value}
          accordion: {}
        }
      }
    )

  _onSideFilterChange: (event)->
    @_onFilterChange(event,
      {list: {
        filter: event.current
        accordion: event.accordion}})

  _onSelectResource: (resource, event)-> # toggles selection item
    event.preventDefault()
    @state.selectedResources.toggle(resource.serialize())


  _onSelectionAllToggle: (event)-> # toggles selection
    event.preventDefault()
    @state.selectedResources.toggleAll(@state.resources.serialize().resources)

  _onHoverMenu: (menu_id, event) ->
    @setState(hoverMenuId: menu_id)

  _currentUrl: () ->
    if router
      parseUrl(window.location.toString()).path
    else
      boxSetUrlParams(@props.get.config.for_url)

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

  _onBatchEdit: (resources, event) ->
    @_sharedOnBatch(resources, event, '/entries/batch_edit_meta_data_by_context')

  _onBatchEditSets: (resources, event) ->
    @_sharedOnBatch(resources, event, '/sets/batch_edit_meta_data_by_context')

  _onBatchDeleteResources: (resources, event) ->
    event.preventDefault()
    @setState(batchDestroyResourcesModal: true, batchDestroyResourcesError: false)
    return false

  _onExecuteBatchDeleteResources: () ->
    resourceIds = @_selectedResourceIdsWithTypes()
    url = setUrlParams('/batch_destroy_resources', {})
    railsFormPut.byData({resource_id: resourceIds}, url, (result) =>
      if result.result == 'error'
        window.scrollTo(0, 0)
        @setState(batchDestroyResourcesError: result.message)
      else
        location.reload()
    )
    return false




  _onBatchPermissionsEdit: (resources, event) ->
    @_sharedOnBatch(resources, event, '/entries/batch_edit_permissions')

  _onBatchPermissionsSetsEdit: (resources, event) ->
    @_sharedOnBatch(resources, event, '/sets/batch_edit_permissions')

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

  _onCreateFilterSet: (config, event)->
    event.preventDefault()
    @_createFilterSetFromConfig(config)

  # TODO: move action to model; use modal for prompt
  _createFilterSetFromConfig: (config)->
    if f.present(name = window.prompt('Name?'))
      xhr
        method: 'POST', url: '/filter_sets'
        headers: 'X-CSRF-Token': getRailsCSRFToken()
        json: filter_set: f.merge(config, title: name)
        , (err, res)->
          url = f.get(res, ['body', 'url'])
          if (err or not url)
            return alert(JSON.stringify(err or 'Error', 0, 2))
          window.location = url

  # public methods:

  setLayout: (layoutMode)=> # NOTE: this is a hack and goes around the router :/
    unless f.includes(f.map(@_allowedLayoutModes(), 'mode'), layoutMode)
      throw new Error "Invalid Layout!"
    @setState(config: f.merge(@state.config, {layout: layoutMode}))

  render: ()->
    {
      get, mods, initial, withBox, fallback, heading, listMods
      fetchRelations, saveable, authToken, children
    } = @props

    # TODO: refactor this + currentQuery into @getInitialState + @getCurrentQuery
    get = f.defaultsDeep \      # combine config in order:
      {config: @state.config},  # - client-side state
      get,                      # - presenter & config (from params)
      {config: initial},        # - per-view initial default config
      config:                   # - default config
        layout: @state.savedLayout || 'grid'
        order: @state.savedOrder || 'created_at DESC'
        show_filter: false

    # FIXME: always get from state!
    resources = @state.resources || get.resources

    config = get.config
    withActions = get.with_actions
    saveable = saveable or false
    # fetching relations enabled by default if layout is grid + withActions + isClient
    fetchRelations = if f.present(fetchRelations)
      fetchRelations
    else
      @state.isClient and withActions and (config.layout is 'grid')

    baseClass = 'ui-polybox'
    boxClasses = cx({ # defaults first, mods last so they can override
      'ui-container': yes
      'midtone': withBox
      'bordered': withBox
    }, mods, baseClass) # but baseClass can't be overridden!

    toolbarClasses = switch
      when f.includes(boxClasses, 'rounded-right')
        'rounded-top-right'
      when f.includes(boxClasses, 'rounded-left')
        'rounded-top-left'
      when f.includes(boxClasses, 'rounded-bottom')
        null
      when f.includes(boxClasses, 'rounded') # also for 'rounded-top'…
        'rounded-top'

    listHolderClasses = cx 'ui-resources-holder',
      pam: withBox

    listClasses = cx(
      config.layout, # base class like "list"
      {
        'vertical': config.layout is 'tiles'
        'active': withActions
      },
      listMods,
      'ui-resources')

    currentQuery = f.merge(
      {list: f.merge f.omit(config, 'for_url')},
      {
        list: filter: config.filter,
        accordion: config.accordion
      })
    permaLink = boxSetUrlParams(@_currentUrl(), currentQuery)
    currentUrl = @_currentUrl()

    resetFilterHref =
      boxSetUrlParams(currentUrl, {list: {page: 1, filter: {}, accordion: {}}})

    resetFilterLink = if resetFilterHref
      if f.present(config.filter) or f.present(config.accordion)
        <Link mods='mlx weak' href={resetFilterHref}>
          <Icon i='undo'/> {'Filter zurücksetzen'}</Link>

    boxTitleBar = () =>
      {filter, layout, for_url, order} = config
      totalCount = f.get(get, 'pagination.total_count')
      isClient = @state.isClient

      layouts = @_allowedLayoutModes().map (layoutMode) =>
        href = boxSetUrlParams(currentUrl, {list: {layout: layoutMode.mode}})
        f.merge layoutMode,
          mods: {'active': layoutMode.mode == layout}
          href: href
          onClick: @_handleChangeInternally # if layoutMode.mode != 'list'

      onSortItemClick = (event, itemKey) =>
        @_handleChangeInternally(event)
        @state.resources.clear()
        if @props.loadChildMediaResources
          @setState(modelReloading: true)
          @props.loadChildMediaResources(itemKey, (child_media_resources) =>
            resources = @_createResourcesModel(child_media_resources, @props.withBox)
            @state.selectedResources.clear()
            @setState(resources: resources, modelReloading: false)
          )

      dropdownItems = [
        {
          label: t('collection_sorting_created_at_asc')
          key: 'created_at ASC'
          href: boxSetUrlParams(currentUrl, list: order: 'created_at ASC')
        },
        {
          label: t('collection_sorting_created_at_desc')
          key: 'created_at DESC'
          href: boxSetUrlParams(currentUrl, list: order: 'created_at DESC')
        },
        {
          label: t('collection_sorting_title_asc')
          key: 'title ASC'
          href: boxSetUrlParams(currentUrl, list: order: 'title ASC')
        },
        {
          label: t('collection_sorting_last_change')
          key: 'last_change'
          href: boxSetUrlParams(currentUrl, list: order: 'last_change')
        }
      ]




      layoutSave = (event) =>
        event.preventDefault()
        simpleXhr(
          {
            method: 'PATCH',
            url: '/sets/' + @props.collectionData.uuid,
            body: 'collection[layout]=' + layout + '\&collection[sorting]=' + order
          },
          (error) =>
            if error
              alert(error)
            else
              @setState(savedLayout: layout, savedOrder: order)
        )
        return false

      centerActions =
        if @props.collectionData && @props.collectionData.editable
          (() =>
            layoutChanged = @state.savedLayout != layout || @state.savedOrder != order
            text = if layoutChanged then t('collection_layout_save') else t('collection_layout_saved')
            [
              <a key="collection_layout" disabled={'disabled' if !layoutChanged}
                className={cx('small ui-toolbar-vis-button button', {active: !layoutChanged})}
                title={text}
                onClick={layoutSave if layoutChanged}>
                <i className="icon-fixed-width icon-eye bright"></i>
                <span className="text">
                  {' ' + text}
                </span>
              </a>
            ]

          )()
        else []

      <BoxTitleBar
        heading={heading or ("#{totalCount} #{t('resources_box_title_count_post')}" if totalCount)}
        mods={toolbarClasses}
        layouts={layouts}
        centerActions={centerActions}
        showSort={true if @props.loadChildMediaResources}
        onSortItemClick={onSortItemClick}
        dropdownItems={dropdownItems}
        selectedSort={order} />

    boxToolBar = () =>
      # NOTE: don't show the bar if not in a box!
      return false if !withBox

      selection = f.presence(@state.selectedResources) or false

      actionsDropdown = ActionsDropdown.createActionsDropdown(
        @props.get.pagination.total_count if @props.get.pagination,
        withActions, selection, saveable, @props.disablePermissionsEdit,
        @state.isClient, @props.collectionData, config, if @props.initial then @props.initial.is_clipboard else false,
        {
          onBatchAddAllToClipboard: @_onBatchAddAllToClipboard
          onBatchAddSelectedToClipboard: @_onBatchAddSelectedToClipboard
          onBatchRemoveAllFromClipboard: @_onBatchRemoveAllFromClipboard
          onBatchRemoveFromClipboard: @_onBatchRemoveFromClipboard
          onBatchAddToSet: @_onBatchAddToSet
          onBatchRemoveFromSet: @_onBatchRemoveFromSet
          onBatchEdit: @_onBatchEdit
          onBatchEditSets: @_onBatchEditSets
          onBatchDeleteResources: @_onBatchDeleteResources
          onBatchPermissionsEdit: @_onBatchPermissionsEdit
          onBatchPermissionsSetsEdit: @_onBatchPermissionsSetsEdit
          onBatchTransferResponsibilityEdit: @_onBatchTransferResponsibilityEdit
          onBatchTransferResponsibilitySetsEdit: @_onBatchTransferResponsibilitySetsEdit
          # onCreateFilterSet: @_onCreateFilterSet
          onHoverMenu: @_onHoverMenu
        })


      selectToggle = if selection && withActions
        selector =
          active: 'Alle abwählen',
          inactive: 'Alle auswählen'
          isActive: selection && !(selection.empty())
          isDirty: selection && resources && !(selection.length() == resources.totalCount)
          onClick: (if selection then @_onSelectionAllToggle)

        labelText = if selector.isActive then selector.active else selector.inactive
        selectClass = 'ui-filterbar-select weak'
        checkboxMods = cx({'active': selector.isActive, 'mid': selector.isDirty})
        selectorStyle = {top: '2px'} # style fix!

        <label className={selectClass} style={selectorStyle} onClick={selector.onClick} >
          <span className='js-only'>
            <span>{labelText} </span>
            <Icon i='checkbox' mods={checkboxMods}/>
          </span>
        </label>


      filterToggleLink = boxSetUrlParams(
        currentUrl, {list: {show_filter: (not config.show_filter)}})

      filterBarProps =
        left: if get.can_filter then do =>
          name = 'Filtern'
          <div>
            <Button name={name} mods={'active': config.show_filter}
              href={filterToggleLink} onClick={@_onFilterToggle}>
              <Icon i='filter' mods='small'/> {name}
            </Button>
            {if f.present(config.filter) then resetFilterLink}
          </div>

        right: if selectToggle || actionsDropdown
          <div>{selectToggle}{actionsDropdown}</div>

        middle: @props.toolBarMiddle

      <BoxToolBar {...filterBarProps}/>

    sidebar = do ({config, dynamic_filters} = get, {isClient} = @state)=>
      return null if not config.show_filter

      <div className='filter-panel ui-side-filter'>
        {if not isClient
          <div><div className='no-js'>
            <SideFilterFallback {...config}/>
            <FilterExamples examples={filter_examples}
              url={config.for_url} query={currentQuery}/>
          </div>
          <div className='js-only'>
            {FilterPreloader}
          </div></div>
        else
          <div className='js-only'>
            <div className='ui-side-filter-search filter-search'>
              <form name='filter_search_form' onSubmit={@_onSearch}>
                <input type='submit' className='unstyled'
                  value='Eingrenzen mit Suchwort'/>
                <input type='text' className='ui-filter-search-input block'
                  ref='filterSearch'
                  defaultValue={f.get(config, ['filter', 'search'])}/>
              </form>
            </div>
            {if (f.isArray(dynamic_filters) and f.present(f.isArray(dynamic_filters)))
              <SideFilter
                dynamic={dynamic_filters}
                current={config.filter or {}}
                accordion={config.accordion or {}}
                onChange={@_onSideFilterChange}/>
            }
          </div>
        }
      </div>

    paginationNav = (resources, staticPagination) =>
      pagination = f.get(f.last(resources.pages), 'pagination') || staticPagination
      return if !withBox or !f.present(pagination)
      return if !(pagination.totalPages > pagination.page)
      # autoscroll:
      if @state.isClient
        isLoading = @state.loadingNextPage
        <div className='ui-actions'>
          {if !@isLoading
            # NOTE: offset means trigger load when page is still *5 screens down*!
            # NOTE: set "random" key to force evaluation on every rerender
            <Waypoint onEnter={@_onFetchNextPage} bottomOffset='-500%' key={(new Date()).getTime()}/>}
          <Button onClick={@_onFetchNextPage}>
            {if !isLoading
              t('pagination_nav_loadnext')
            else
              t('pagination_nav_nextloading')}
          </Button>
        </div>

      # static fallback:
      else do ({config, pagination} = get)=>
        navLinks =
          current:
            href: permaLink
            onClick: @_handleChangeInternally
          prev: if pagination.prev
            href: boxSetUrlParams(currentUrl, list: pagination.prev)
          next: if pagination.next
            href: boxSetUrlParams(currentUrl, list: pagination.next)

        <div className='no-js'>
          <ActionsBar>
            <PaginationNavFallback {...navLinks}/>
          </ActionsBar>
        </div>

    # component:
    <div className={boxClasses}>
      {
        if @state.showBatchTransferResponsibility

          resource_ids = f.map(@state.batchTransferResponsibilityResources, 'uuid')

          responsible_uuid = @state.batchTransferResponsibilityResources[0].responsible_user_uuid
          responsible = @state.batchTransferResponsibilityResources[0].responsible

          batch_type = @state.selectedResources.first().type

          <Modal widthInPixel={800}>
            <EditTransferResponsibility
              authToken={@props.authToken}
              batch={true}
              resourceType={batch_type}
              singleResource={null}
              batchResourceIds={resource_ids}
              responsibleUuid={responsible_uuid}
              responsible={responsible}
              onClose={@_hideBatchTransferResponsibility}
              onSaved={() -> location.reload()} />
          </Modal>
      }

      {if withBox then boxTitleBar()}
      {if withBox then boxToolBar()}

      <div className={listHolderClasses}>
        <div className='ui-container table auto'>
          {sidebar}

          {# main list:}
          <div className='ui-container table-cell table-substance'>
            {children}
            {if @state.modelReloading
              <Preloader />
            else if not f.present(resources) or resources.length == 0 then do ()->
              return null if !fallback
              if !f.isBoolean(fallback)
                fallback # we are given a fallback message, use it
              else       # otherwise, build default fallback message:
                <FallBackMsg>
                  {'Keine Inhalte verfügbar'}
                  {if resetFilterLink
                    <br/>}
                  {resetFilterLink}
                </FallBackMsg>
            else
              <ul className={listClasses}>
                {(resources.pages || [{resources}]).map (page, i)=>
                  <li className='ui-resources-page' key={i}>

                    {if withBox and (pagination = f.presence(page.pagination))
                      if (pagination.totalPages > 1)

                        onSelectPage = null
                        checkboxMods = cx({'active': false, 'mid': false})

                        if @state.isClient

                          selection = @state.selectedResources
                          selectionCountOnPage =
                            if selection
                              f.size(
                                page.resources.filter (item) =>
                                  selection.contains(item.serialize())
                              )
                            else
                              0

                          fullPageCount =
                            if page.pagination.totalPages == page.pagination.page
                              if page.pagination.totalCount < resources.perPage * page.pagination.totalPages
                                page.pagination.totalCount - (page.pagination.totalPages - 1) * resources.perPage
                              else
                                resources.perPage
                            else
                              resources.perPage

                          checkboxMods = cx({'active': selectionCountOnPage > 0, 'mid': selectionCountOnPage < fullPageCount})

                          onSelectPage = (event) ->
                            event.preventDefault()
                            if selectionCountOnPage > 0
                              page.resources.forEach (item) ->
                                selection.remove(item.serialize())
                            else
                              page.resources.forEach (item) ->
                                selection.add(item.serialize())

                        <PageCounter
                          href={page.url}
                          page={pagination.page}
                          total={(pagination.totalPages)}
                          onSelectPage={onSelectPage}
                          checkboxMods={checkboxMods}
                          />}

                    <ul className='ui-resources-page-items'>
                      {
                        page.resources.map (item)=>
                          key = item.uuid or item.cid

                          if withBox
                            selection = @state.selectedResources
                            # selection defined means selection is enabled
                            if @state.isClient && selection
                              isSelected = @state.selectedResources.contains(item.serialize())
                              onSelect = f.curry(@_onSelectResource)(item)
                              # if in selection mode, intercept clicks as 'select toggle'
                              onClick = if config.layout == 'miniature'
                                (if !selection.empty() then onSelect)
                              # when hightlighting editables, we just dim everything else:

                              style = if ActionsDropdown.isResourceNotInScope(item, isSelected, @state.hoverMenuId)
                                {opacity: 0.35}


                          listMetadata = null
                          if @state.isClient && config.layout == 'list'
                            listMetadata = @state.listMetadata[item.uuid]
                            unless listMetadata
                              setTimeout(
                                () =>
                                  @_tryLoadListMetadata(item)
                                ,
                                10
                              )



                          # TODO: get={model}
                          <ResourceThumbnail elm='div'
                            style={style}
                            get={item}
                            isClient={@state.isClient} fetchRelations={fetchRelations}
                            isSelected={isSelected} onSelect={onSelect} onClick={onClick}
                            authToken={authToken} key={key}
                            pinThumb={config.layout == 'tiles'}
                            listThumb={config.layout == 'list'}
                            indexMetaData={listMetadata}
                            loadingMetadata={@state.loadingListMetadataResource == item.uuid}
                            showDraftBadge={@props.initial and @props.initial.is_clipboard}
                            />
                      }

                    </ul>

                </li>}
              </ul>
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
            get={null} onClose={@_onCloseModal} returnTo={currentUrl}/>
      }
      {
        if @state.batchRemoveFromSet
          <BatchRemoveFromSetModal collectionUuid={@props.collectionData.uuid}
            resourceIds={@_selectedResourceIdsWithTypes()} authToken={@props.authToken}
            get={null} onClose={@_onCloseModal} returnTo={currentUrl}/>
      }
      {
        if @state.batchDestroyResourcesModal
          <Modal widthInPixel={400}>
            <div style={{margin: '20px', marginBottom: '20px', textAlign: 'center'}}>
              {
                if @state.batchDestroyResourcesError
                  <div className="ui-alerts" style={marginBottom: '10px'}>
                    <div className="error ui-alert">
                      {@state.batchDestroyResourcesError}
                    </div>
                  </div>
              }
              <div style={{marginBottom: '20px', textAlign: 'center'}}>
                {t('batch_destroy_resources_ask_1')}{@_selectedResourceIdsWithTypes().length}{t('batch_destroy_resources_ask_2')}
              </div>
              <div className="ui-actions" style={{padding: '10px'}}>
                <a onClick={@_onCloseModal} className="link weak">{t('batch_destroy_resources_cancel')}</a>
                <button className="primary-button" type="submit" onClick={@_onExecuteBatchDeleteResources}>
                  {t('batch_destroy_resources_ok')}
                </button>
              </div>
            </div>
          </Modal>
      }

    </div>

# export helper
module.exports.boxSetUrlParams = boxSetUrlParams
# Partials and UI-Components only used here:

PageCounter = ({href, page, total, onSelectPage, checkboxMods} = @props)->
  # TMP: this link causes to view to start loading at page Nr. X
  #      it's ONLY needed for some edge cases (viewing page N + 1),
  #      where N = number of pages the browser can handle (memory etc)
  #      BUT the UI is unfinished in this case (no way to scroll "backwards")
  #      SOLUTION: disable the link-click so it is not clicked accidentally
  <div className='ui-resources-page-counter ui-pager small'>
    <div style={{display: 'inline-block'}}>Seite {page} von {total}</div>
    <div style={{float: 'right', position: 'relative'}} onClick={onSelectPage}>
      <span style={{marginRight: '20px'}}>Seite auswählen</span>
      <Icon style={{position: 'absolute', right: '0px', top: '0px'}} mods={checkboxMods} i='checkbox' />
    </div>
  </div>

SideFilterFallback = ({filter} = @props)->
  filter = f.presence(filter) or {}
  <div className='ui-side-filter-search filter-search'>
    <RailsForm name='list' method='get' mods='prm'>
      <input type='hidden' name='list[show_filter]' value='true'/>
      <textarea name='list[filter]' rows='25'
        style={{fontFamily: 'monospace', fontSize: '1.1em', width: '100%'}}
        defaultValue={JSON.stringify(filter, 0, 2)}/>
      <Button type='submit'>Submit</Button>
    </RailsForm>
  </div>

BoxTitleBar = ({heading, centerActions, layouts, mods, showSort, onSortItemClick, dropdownItems, selectedSort} = @props)->

  style = {minHeight: '1px'} # Make sure col2of6 fills its space (min height ensures that following float left are blocked)

  classes = cx('ui-container inverted ui-toolbar pvx', mods)
  style = {minHeight: '1px'} # Make sure col2of6 fills its space (min height ensures that following float left are blocked)
  <div className={classes}>
    <h2 className='ui-toolbar-header pls col2of6' style={style}>{heading}</h2>
    <div className='col2of6' style={{textAlign: 'center'}}>
      {# Action Buttons: }
      {if f.any(centerActions)
        <ButtonGroup mods='tertiary small center mls'>
          {centerActions}
        </ButtonGroup>
      }
    </div>
    <div className='ui-toolbar-controls by-right'> {# removed col2of6 because of minimum width}
      {# Layout Switcher: }
      <ButtonGroup mods='tertiary small right mls'>
        {layouts.map (layout)->
          mods = cx 'small', 'ui-toolbar-vis-button', layout.mods
          <Button
            mode={layout.mode} title={layout.title} icon={layout.icon}
            href={layout.href} onClick={layout.onClick}
            mods={mods} key={layout.mode}>
            <Icon i={layout.icon} title={layout.title}/>
          </Button>
        }
      </ButtonGroup>
      {
        if showSort
          <SortDropdown items={dropdownItems} selectedKey={selectedSort}
            onItemClick={onSortItemClick} />
      }
    </div>
  </div>

PaginationNavFallback = ({current, next, prev} = @props)->
  <ButtonGroup mods='mbm'>
    <Button {...prev} mods='mhn' disabled={not prev}>{t('pagination_nav_prevpage')}</Button>
    <Button {...current} mods='mhn'>{t('pagination_nav_thispage')}</Button>
    <Button {...next} mods='mhn' disabled={not next}>{t('pagination_nav_prevpage')}</Button>
  </ButtonGroup>

FallBackMsg = ({children} = @props)->
  <div className='pvh mth mbl'>
    <div className='title-l by-center'>{children}</div>
  </div>

FilterPreloader = (
  <div className='ui-slide-filter-item'>
    <div className='title-xs by-center'>
      Filter werden geladen</div>
      <Preloader mods='small'/>
  </div>)

FilterExamples = ({url, query, examples} = @props)->
  <div>
    <h4>Examples:</h4>
    <ul>
      {f.map examples, (example, name)->
        params = {list: {page: 1, filter: JSON.stringify(example, 0, 2)}}
        <li key={name}>
          <Link href={setUrlParams(url, query, params)}>{name}</Link>
        </li>
      }
    </ul>
  </div>

filter_examples = {
  "Search: 'still'": {
    "search": "still"
  },
  "Title: 'diplom'": {
    "meta_data": [{ "key": "madek_core:title", "match": "diplom" }]
  },
  "Uses Meta-Key 'Gattung'": {
    "meta_data": [ { "key": "media_content:type" } ]
  },
  "Permissions: public": {
    "permissions": [{ "key": "public", "value": true }]
  },
  "Media File: Content-Type jpeg": {
    "media_files": [{ "key": "content_type", "value": "image/jpeg" }]
  },
  "Media File: Extension pdf": {
    "media_files": [{ "key": "extension", "value": "pdf" }]
  }
}
