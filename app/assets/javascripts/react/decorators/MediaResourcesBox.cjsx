React = require('react')
f = require('active-lodash')
ampersandReactMixin = require('ampersand-react-mixin')
ui = require('../lib/ui.coffee')
{parseMods, cx} = ui
t = ui.t('de')
setUrlParams = require('../../lib/set-params-for-url.coffee')
resourceListParams = require('../../shared/resource_list_params.coffee')

Waypoint = require('react-waypoint')
RailsForm = require('../lib/forms/rails-form.cjsx')
ResourceThumbnail = require('./ResourceThumbnail.cjsx')
{ Button, ButtonGroup, Icon, Link, Preloader, Dropdown, ActionsBar
} = require('../ui-components/index.coffee')
MenuItem = Dropdown.MenuItem
SideFilter = require('../ui-components/ResourcesBox/SideFilter.cjsx')
BoxToolBar = require('../ui-components/ResourcesBox/BoxToolBar.cjsx')

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

viewConfigProps = React.PropTypes.shape
  show_filter: React.PropTypes.bool
  filter: filterConfigProps
  layout: React.PropTypes.oneOf(['tiles', 'miniature', 'grid', 'list'])
  pagination: React.PropTypes.shape
    prev: React.PropTypes.shape(page: React.PropTypes.number.isRequired)
    next: React.PropTypes.shape(page: React.PropTypes.number.isRequired)
  for_url: React.PropTypes.shape
    path: React.PropTypes.string.isRequired
    query: React.PropTypes.object

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
    config: {},
    batchAddToSet: false,
    batchRemoveFromSet: false,
    savedLayout: @props.collectionData.layout if @props.collectionData
    listMetadata: {}
    loadingListMetadataResource: null
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

  _createResourcesModel: () ->
    collectionClass = switch @props.get.type
      when 'MediaResources' then CollectionChildren
      when 'MediaEntries' then MediaEntries
      when 'Collections' then Collections
    if collectionClass
      if @props.withBox && f.present(f.get(@props, 'get.pagination.total_count'))
        if !collectionClass.Paginated then throw new Error('Collection has no Pagination!')
        (new collectionClass.Paginated(@props.get))
      else
        (new collectionClass(@props.get.resources))


  _tryLoadListMetadata: (resourceType, resourceUuid) ->
    if not @state.loadingListMetadataResource
      @setState({loadingListMetadataResource: resourceUuid})
      LoadXhr({
        method: 'GET',
        url:
          if resourceType == 'Collection'
            '/sets/' + resourceUuid + '.json?___sparse={"meta_data":{}}'
          else if resourceType == 'MediaEntry'
            '/entries/' + resourceUuid + '.json?___sparse={"meta_data":{}}'
          else
            console.error('Unknown resource type for loading meta data: ' + resourceType)

      },
      (result, json) =>
        @state.listMetadata[resourceUuid] = json.meta_data
        @setState({loadingListMetadataResource: null})
      )


  componentWillMount: ()->
    resources = if f.get(@props, 'get.resources.isCollection')
      @props.get.resources # if already initialized just use that
    else
      @_createResourcesModel()
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

    # selection status is managed in ampersand-collection
    if @props.get.type is 'MediaResources'
      selection = new CollectionChildren()
    else if @props.get.type is 'MediaEntries'
      selection = new MediaEntries()

    if selection
      # set up auto-update for it:
      f.each ['add', 'remove', 'reset', 'change'], (eventName)=>
        selection.on(eventName, ()=> @forceUpdate() if @isMounted())
      @doOnUnmount.push(selection.off)

    if @state.resources
      @fetchNextPage = f.throttle(((c)=> @state.resources.fetchNext(c)), 1000)
      @doOnUnmount.push(@fetchNextPage.cancel())
    @setState(isClient: true, router: router, selectedResources: selection)

  # client-side link handlers:
  # - for state changes that don't need new data (like visual changes):
  _handleChangeInternally: (event)->
    handleLinkIfLocal(event, router.goTo)

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
    params = currentParams = {list: f.omit(@state.config, 'for_url')}

    params = f.merge(params,
      {list: {page: 1}}) # make sure that the new result starts on page 1

    params.list.accordion = JSON.stringify(newParams.list.accordion)
    params.list.filter = JSON.stringify(newParams.list.filter)
    newLocation = setUrlParams(@props.for_url, params)
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

  _onAccordion: (event)->
    @_onFilterChange(event,
      {list: {
        filter: event.current
        accordion: event.accordion}})

  _onSelectResource: (resource, event)-> # toggles selection item
    event.preventDefault()
    selection = @state.selectedResources
    if selection.has(resource)
      selection.remove(resource)
    else
      selection.add(resource)

  _onSelectionAllToggle: (event)-> # toggles selection
    event.preventDefault()
    selection = @state.selectedResources
    if selection.isEmpty()
      selection.set(@state.resources.models)
    else
      selection.reset()

  _onHiglightEditable: (bool, event)->
    if(!@state.selectedResources || @state.selectedResources.isEmpty()) then return
    @setState(higlightBatchEditable: bool)

  _onHiglightPermissionsEditable: (bool, event)->
    if(!@state.selectedResources || @state.selectedResources.isEmpty()) then return
    @setState(higlightBatchPermissionsEditable: bool)

  _currentUrl: () ->
    setUrlParams(@props.get.config.for_url)

  _onBatchEdit: (event)->
    event.preventDefault()
    selected = f.map(@state.selectedResources.getBatchEditableItems(), 'uuid')
    batchEditUrl = setUrlParams('/entries/batch_edit_context_meta_data', {id: selected, return_to: @_currentUrl()})
    window.location = batchEditUrl # SYNC!

  _onBatchPermissionsEdit: (event)->
    event.preventDefault()
    selected = f.map(@state.selectedResources.getBatchPermissionEditableItems(), 'uuid')
    batchEditUrl = setUrlParams('/entries/batch_edit_permissions', {id: selected, return_to: @_currentUrl()})
    window.location = batchEditUrl # SYNC!

  _batchAddToSetIds: () ->
    @state.selectedResources.map (model) ->
      {
        uuid: model.uuid
        type: model.getType()
      }

  _onBatchAddToSet: (event)->
    event.preventDefault()
    @setState(batchAddToSet: true)
    return false

  _batchRemoveFromSetIds: () ->
    @state.selectedResources.map (model) ->
      {
        uuid: model.uuid
        type: model.getType()
      }

  _onBatchRemoveFromSet: (event)->
    event.preventDefault()
    @setState(batchRemoveFromSet: true)
    return false

  _onCloseModal: () ->
    @setState(batchAddToSet: false)
    @setState(batchRemoveFromSet: false)

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
    currentUrl = setUrlParams(config.for_url, currentQuery)

    resetFilterHref =
      setUrlParams(config.for_url,
        f.merge(currentQuery, {
          list: {
            page: 1
            filter: JSON.stringify({})
            accordion: JSON.stringify({})
          }
        })
      )

    resetFilterLink = if resetFilterHref
      if f.present(config.filter) or f.present(config.accordion)
        <Link mods='mlx weak' href={resetFilterHref}>
          <Icon i='undo'/> {'Filter zurücksetzen'}</Link>

    boxTitleBar = () =>
      {filter, layout, for_url} = config
      totalCount = f.get(get, 'pagination.total_count')
      isClient = @state.isClient

      layouts = @_allowedLayoutModes().map (layoutMode) =>
        href = setUrlParams(for_url, currentQuery, list: layout: layoutMode.mode)
        f.merge layoutMode,
          mods: {'active': layoutMode.mode == layout}
          href: href
          onClick: @_handleChangeInternally # if layoutMode.mode != 'list'

      layoutSave = (event) =>
        event.preventDefault()
        simpleXhr(
          {
            method: 'PATCH',
            url: '/sets/' + @props.collectionData.uuid,
            body: 'collection[layout]=' + layout
          },
          (error) =>
            if error
              alert(error)
            else
              @setState(savedLayout: layout)
        )
        return false

      centerActions =
        if @props.collectionData && @props.collectionData.editable
          (() =>
            layoutChanged = @state.savedLayout != layout
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
        centerActions={centerActions} />

    boxToolBar = () =>
      # NOTE: don't show the bar if not in a box!
      return false if !withBox

      isClient = @state.isClient
      selection = f.presence(@state.selectedResources) or false
      batchEditables = selection.getBatchEditableItems() if selection
      batchPermissionEditables = selection.getBatchPermissionEditableItems() if selection
      filterToggleLink = setUrlParams(config.for_url, currentQuery,
        list: show_filter: (not config.show_filter))

      # batch actions. presence of action key shows it in menu,
      #                presence of 'click' function means it is enabled.
      actions = if withActions
        addToSet: if selection && (get.type is 'MediaEntries' || get.type is 'MediaResources')
          click: (if !selection.isEmpty() then @_onBatchAddToSet)

        edit: if selection && (get.type is 'MediaEntries' || get.type is 'MediaResources')
          click: (if f.present(batchEditables) then @_onBatchEdit)
          hover: f.curry(@_onHiglightEditable)(true)
          unhover: f.curry(@_onHiglightEditable)(false)

        managePermissions: if !@props.disablePermissionsEdit && selection && (get.type is 'MediaEntries' || get.type is 'MediaResources')
          click: (if f.present(batchPermissionEditables) then @_onBatchPermissionsEdit)
          hover: f.curry(@_onHiglightPermissionsEditable)(true)
          unhover: f.curry(@_onHiglightPermissionsEditable)(false)

        save: if isClient and saveable
          click: (if f.present(config.filter) then f.curry(@_onCreateFilterSet)(config))

        removeFromSet: if selection && f.present(@props.collectionData) && (get.type is 'MediaEntries' || get.type is 'MediaResources')
          click: (if !selection.isEmpty() then @_onBatchRemoveFromSet)

        # TODO: batch delete
        # delete: ->
        #   click: alert('not implemented!')

      actionsDropdown = if f.any(f.values(actions))
        <Dropdown mods='stick-right mlm'
          toggle={'Aktionen'} toggleProps={{className: 'button'}}>

          <Dropdown.Menu className='ui-drop-menu'>

            {if actions.addToSet
              <MenuItem onClick={actions.addToSet.click}>
                <Icon i="move" mods="ui-drop-icon"
                /> <span className="ui-count">
                  {selection.length}
                </span> {t('resources_box_batch_actions_addtoset')}
              </MenuItem>}

            {if actions.removeFromSet
              <MenuItem onClick={actions.removeFromSet.click}>
                <Icon i="close" mods="ui-drop-icon"
                /> <span className="ui-count">
                  {selection.length}
                </span> {t('resources_box_batch_actions_removefromset')}
              </MenuItem>
            }

            {if actions.edit
              <MenuItem
                onClick={actions.edit.click} onMouseEnter={actions.edit.hover} onMouseLeave={actions.edit.unhover}>
                <Icon i="pen" mods="ui-drop-icon"
                /> <span className="ui-count">
                  {batchEditables.length}
                </span> {t('resources_box_batch_actions_edit')}
              </MenuItem>}

            {if actions.managePermissions
              <MenuItem onClick={actions.managePermissions.click}>
                <Icon i="lock" mods="ui-drop-icon"
                /> <span className="ui-count">
                  {batchEditables.length}
                </span> {t('resources_box_batch_actions_managepermissions')}
              </MenuItem>}

            {if actions.delete
              <MenuItem className="separator"/>}
            {if actions.delete
              <MenuItem onClick={actions.delete.click}>
                <Icon i="trash" mods="ui-drop-icon"
                  /> {t('resources_box_batch_actions_delete')}
              </MenuItem>}

            {if actions.save
              <MenuItem className="separator"/>}
            {if actions.save
              <MenuItem onClick={actions.save.click}>
                <Icon i="filter" mods="ui-drop-icon"/> {t('resources_box_batch_actions_save')}
              </MenuItem>}

          </Dropdown.Menu>
        </Dropdown>

      selectToggle = if selection && withActions
        selector =
          active: 'Alle abwählen',
          inactive: 'Alle auswählen'
          isActive: selection && !(selection.isEmpty())
          isDirty: selection && resources && !(selection.length == resources.length)
          onClick: (if selection then @_onSelectionAllToggle)

        labelText = if selector.isActive then selector.active else selector.inactive
        selectClass = 'ui-filterbar-select weak'
        checkboxMods = cx({'active': selector.isActive, 'mid': selector.isDirty})
        selectorStyle = {top: '2px'} # style fix!

        <label className={selectClass} {...selector} style={selectorStyle}>
          <span className='js-only'>
            <span>{labelText} </span>
            <Icon i='checkbox' mods={checkboxMods}/>
          </span>
        </label>


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
              <SideFilter dynamic={dynamic_filters} current={config.filter or {}}
                accordion={config.accordion or {}} onChange={@_onAccordion}
                url={config.for_url} query={currentQuery}/>
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
            # NOTE: offset means trigger when next page is still way *down*!
            # NOTE: set "random" key to force evaluation on every rerender
            <Waypoint onEnter={@_onFetchNextPage} bottomOffset='-90%' key={(new Date()).getTime()}/>}
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
            href: currentUrl
            onClick: @_handleChangeInternally
          prev: if pagination.prev
            href: setUrlParams(config.for_url, currentQuery, list: pagination.prev)
          next: if pagination.next
            href: setUrlParams(config.for_url, currentQuery, list: pagination.next)

        <div className='no-js'>
          <ActionsBar>
            <PaginationNavFallback {...navLinks}/>
          </ActionsBar>
        </div>

    # component:
    <div className={boxClasses}>
      {if withBox then boxTitleBar()}
      {if withBox then boxToolBar()}

      <div className={listHolderClasses}>
        <div className='ui-container table auto'>
          {sidebar}

          {# main list:}
          <div className='ui-container table-cell table-substance'>
            {children}
            {if not f.present(resources) or resources.length == 0 then do ()->
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
                        <PageCounter
                          href={page.url}
                          page={pagination.page}
                          total={(pagination.totalPages)}/>}

                    <ul className='ui-resources-page-items'>
                      {
                        page.resources.map (item)=>
                          key = item.uuid or item.cid

                          if withBox
                            selection = @state.selectedResources
                            # selection defined means selection is enabled
                            if @state.isClient && selection
                              isSelected = @state.selectedResources.has(item)
                              onSelect = f.curry(@_onSelectResource)(item)
                              # if in selection mode, intercept clicks as 'select toggle'
                              onClick = if config.layout == 'miniature'
                                (if !selection.isEmpty() then onSelect)
                              # when hightlighting editables, we just dim everything else:
                              style = if @state.higlightBatchEditable and (!item.isBatchEditable) \
                                or @state.higlightPermissionsBatchEditable and (!item.isBatchPermissionsEditable)
                                  {opacity: 0.35}

                          listMetadata = null
                          if @state.isClient
                            listMetadata = @state.listMetadata[item.uuid]
                            unless listMetadata
                              setTimeout(
                                () =>
                                  # debugger
                                  @_tryLoadListMetadata(item.type, item.uuid)
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
                            loadingMetadata={@state.loadingListMetadataResource == item.uuid}/>
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
        if @state.batchAddToSet
          <BatchAddToSetModal resourceIds={@_batchAddToSetIds()} authToken={@props.authToken}
            get={null} onClose={@_onCloseModal} returnTo={@state.config.for_url.path}/>
      }
      {
        if @state.batchRemoveFromSet
          <BatchRemoveFromSetModal collectionUuid={@props.collectionData.uuid}
            resourceIds={@_batchRemoveFromSetIds()} authToken={@props.authToken}
            get={null} onClose={@_onCloseModal} returnTo={@state.config.for_url.path}/>
      }

    </div>

# Partials and UI-Components only used here:

PageCounter = ({href, page, total} = @props)->
  <Link href={href}
    className='ui-resources-page-counter ui-pager small'
    >Seite {page} von {total}</Link>

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

BoxTitleBar = ({heading, centerActions, layouts, mods} = @props)->
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
    <div className='ui-toolbar-controls by-right col2of6'>
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
