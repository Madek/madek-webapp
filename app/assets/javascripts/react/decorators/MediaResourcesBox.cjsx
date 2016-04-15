React = require('react')
f = require('active-lodash')
classList = require('classnames/dedupe')
qs = require('qs')
ampersandReactMixin = require('ampersand-react-mixin')
setUrlParams = require('../../lib/set-params-for-url.coffee')
resourceListParams = require('../../shared/resource_list_params.coffee')
RailsForm = require('../lib/forms/rails-form.cjsx')
ResourceThumbnail = require('./ResourceThumbnail.cjsx')
{ Button, ButtonGroup, Icon, Link, ActionsBar, FilterBar, SideFilter
} = require('../ui-components/index.coffee')
MediaEntriesCollection = require('../../models/media-entries.coffee')
router = null # client-side only

xhr = require('xhr')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')

# Props/Config overview:
# - props.get.with_actions = should the UI offer any interaction
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

# "const": allowed layout modes + config
LAYOUT_MODES = [
  # {mode: 'tiles', title: 'Kachel-Ansicht', icon: 'vis-pins'},
  {mode: 'miniature', title: 'Miniatur-Ansicht', icon: 'vis-miniature'},
  {mode: 'grid', title: 'Raster-Ansicht', icon: 'vis-grid'},
  # {mode: 'list', title: 'Listen-Ansicht', icon: 'vis-list'}
]

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
    authToken: React.PropTypes.string.isRequired
    get: React.PropTypes.shape
      # resources: React.PropTypes.array # TODO: array of ampersandCollection
      with_actions: React.PropTypes.bool # toggles actions, hover, flyout
      can_filter: React.PropTypes.bool # if true, get.resources can be filtered
      config: viewConfigProps # <- config that is part of the URL!
      dynamic_filters: React.PropTypes.array

  mixins: [ampersandReactMixin]
  getObservedItems: ()-> # ampersandReactMixin!
    [f.get(@props, ['get', 'resources'])]

  # kick of client-side mode:
  getInitialState: ()-> {isClient: false, config: {}}
  componentDidMount: ()->
    router = require('../../lib/router.coffee')
    # listen to history and set state from params:
    router.listen (location)=>
      @setState(config: f.merge(@state.config, resourceListParams(location)))
    # start the router (also immediatly calls listener(s) once if already attached!)
    router.start()

    # selection status is managed in ampersand-collection
    selection = new MediaEntriesCollection()
    # set up auto-update for it:
    f.each ['add', 'remove', 'reset', 'change'], (eventName)=>
      selection.on(eventName, ()=> @forceUpdate() if @isMounted())
    @setState(isClient: true, selectedResources: selection)

  componentWillUnmount: ()->
    if @state.selectedResources then @state.selectedResources.off()

  # client-side link handlers:
  # - for state changes that don't need new data (like visual changes):
  _handleChangeInternally: (event)->
    handleLinkIfLocal(event, router.goTo)

  # # - for state changes that update the resources (like filter):
  # _handleRequestInternally: (event)->
  #   handleLinkIfLocal(event, alert)

  # - custom actions:
  _onFilterChange: (event, newParams)->
    event.preventDefault() if event && f.isFunction(event.preventDefault)
    currentParams = {list: f.omit(@state.config, 'for_url')}
    params = f.merge(newParams,
      {list: {page: 1}}) # make sure that the new result starts on page 1
    window.location = setUrlParams(@props.for_url, currentParams, params) # SYNC!

  _onFilterToggle: (event)->
    # NOTE: if dynfilters are loaded, just open/close sidebar in client
    if f.present(f.get(@props, ['get', 'dynamic_filters']))
      event.preventDefault()
      @handleChangeInternally(event)
    return undefined

  _onSearch: (event)->
    @_onFilterChange(event,
      {list: {filter: JSON.stringify({search: @refs.filterSearch.value})}})

  _onAccordion: (event)->
    @_onFilterChange(event,
      {list: {
        filter: JSON.stringify(event.current)
        accordion: JSON.stringify(event.accordion)}})

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
      selection.set(@props.get.resources)
    else
      selection.reset()

  _onBatchEdit: (event)->
    event.preventDefault()
    selection = @state.selectedResources
    selected = f.map(selection.serialize(), 'uuid')
    newUrl = setUrlParams('/entries/batch_meta_data_edit', {id: selected})
    window.location = newUrl # SYNC!

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


  render: ()->
    {get, mods, initial, withBox, saveable, authToken} = @props

    # TODO: refactor this + currentQuery into @getInitialState + @getCurrentQuery
    get = f.defaultsDeep \      # combine config in order:
      {config: @state.config},  # - client-side state
      get,                      # - presenter & config (from params)
      {config: initial},        # - per-view initial default config
      config:                   # - default config
        layout: 'grid'
        show_filter: false

    config = get.config
    withActions = get.with_actions
    saveable = saveable or false

    baseClass = 'ui-polybox'
    boxClasses = classList({ # defaults first, mods last so they can override
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

    listHolderClasses = classList 'ui-resources-holder',
      pam: withBox

    listClasses = classList(config.layout, {
      'vertical': config.layout is 'tiles'
      'active': withActions
    }, 'ui-resources')

    currentQuery = f.merge(
      {list: f.merge f.omit(config, 'for_url')},
      {
        list: filter: JSON.stringify(config.filter),
        accordion: JSON.stringify(config.accordion)
      })
    currentUrl = setUrlParams(config.for_url, currentQuery)

    resetFilterHref =
      setUrlParams(config.for_url, currentQuery, list:
        page: 1, filter: {}, accordion: {})

    resetFilterLink = if resetFilterHref
      if f.present(config.filter) or f.present(config.accordion)
        <Link mods='mlx weak' href={resetFilterHref}>
          <Icon i='undo'/> {'Filter zurücksetzen'}</Link>

    BoxToolBar = if withBox then do ()=>
      {filter, layout, for_url} = config
      isClient = @state.isClient
      selection = f.presence(@state.selectedResources) or false

      layouts = LAYOUT_MODES.map (itm)=>
        href = setUrlParams(for_url, currentQuery, list: layout: itm.mode)
        f.merge itm,
          mods: {'active': layout is itm.mode}
          href: href
          onClick: @_handleChangeInternally

      actions = if withActions
        # jsOnly: true # TODO: <- implement fallback
        save: if saveable
          children: <Icon i='filter' mods='small' title='Als FilterSet speichern'/>
          onClick: if isClient && f.present(filter)
            f.curry(@_onCreateFilterSet)(config)

        # TODO: add to collection
        # add:
        #   children: <Icon i='move' mods='small' title='Zu Set hinzufügen'/>
        #   onClick: if isClient && selection && !selection.isEmpty()
        #     ()-> alert('NOT IMPLEMENTED: add to collection!')

        batch_edit:
          children: <Icon i='pen' mods='small' title='Auswahl bearbeiten'/>
          onClick: if isClient && selection && !selection.isEmpty()
            @_onBatchEdit

      <UiToolBar
        heading="#{get.pagination.total_count} #{'Inhalte'}"
        mods={toolbarClasses}
        actions={actions} layouts={layouts}/>

    BoxFilterBar = do =>
      # NOTE: don't show the bar at all if no 'filter' button!
      return null if (!withBox or !get.can_filter)

      selection = f.presence(@state.selectedResources) or false
      filterToggleLink = setUrlParams(config.for_url, currentQuery,
        list: show_filter: (not config.show_filter))

      props =
        filter:
          toggle:
            name: 'Filtern'
            mods: 'active' if config.show_filter
            href: filterToggleLink
            onClick: @_onFilterToggle
          reset: resetFilterLink if f.present(config.filter)
        select:
          active: 'Alle abwählen',
          inactive: 'Alle auswählen'
          isActive: selection && !(selection.isEmpty())
          isDirty: selection && !(selection.length == get.resources.length)
          onClick: @_onSelectionAllToggle

        # TODO: multi resource switcher
        # toggles: [
        #   {name: 'Medieneinträge'},
        #   {name: 'Sets'} ]

      <FilterBar {...props}/>

    Sidebar = do ({config, dynamic_filters} = get, {isClient} = @state)=>
      return null if not config.show_filter

      # TMP: ignore invalid dynamicFilters
      if !(f.isArray(dynamic_filters) and f.present(f.isArray(dynamic_filters)))
        return null

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
            <SideFilter dynamic={dynamic_filters} current={config.filter or {}}
              accordion={config.accordion or {}} onChange={@_onAccordion}
              url={config.for_url} query={currentQuery}/>
          </div>
        }
      </div>

    paginationNav = if withBox then do ({config, pagination} = get)=>
      navLinks =
        current:
          href: currentUrl
          onClick: @_handleChangeInternally
        prev: if pagination.prev
          href: setUrlParams(config.for_url, currentQuery, list: pagination.prev)
        next: if pagination.next
          href: setUrlParams(config.for_url, currentQuery, list: pagination.next)
      <ActionsBar>
        <UiPaginationNav {...navLinks}/>
      </ActionsBar>

    # component:
    <div className={boxClasses}>
      {BoxToolBar}
      {BoxFilterBar}

      <div className={listHolderClasses}>
        <div className='ui-container table auto'>
          {Sidebar}

          {# main list:}
          <div className='ui-container table-cell table-substance'>
            {if not f.present(get.resources)
              <FallBackMsg>
                {'Keine Inhalte verfügbar'}
                {if resetFilterLink
                  <br/>}
                {resetFilterLink}
              </FallBackMsg>
            else
              <ul className={listClasses}>
                <li className='ui-resources-page'>
                  {if withBox and get.pagination.total_pages > 1
                    <PageCounter
                      href={currentUrl}
                      page={get.config.page}
                      total={get.pagination.total_pages}/>}

                  <ul className='ui-resources-page-items'>
                  {get.resources.map (item)=>
                    key = item.uuid or item.cid

                    if withBox
                      selection = @state.selectedResources
                      if @state.isClient && selection
                        isSelected = @state.selectedResources.has(item)
                        onSelect = f.curry(@_onSelectResource)(item)
                        # if in selection mode, intercept clicks as 'select toggle'
                        onClick = if config.layout == 'miniature'
                          (if !selection.isEmpty() then onSelect)

                    # TODO: get={model}
                    <ResourceThumbnail elm='div' isClient={@state.isClient}
                      get={item}
                      isSelected={isSelected} onSelect={onSelect} onClick={onClick}
                      authToken={authToken} key={key}/>}
                  </ul>

                </li>
              </ul>
            }
            {paginationNav}
          </div>

        </div>
      </div>

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

UiToolBar = ({heading, actions, layouts, mods} = @props)->
  classes = classList('ui-container inverted ui-toolbar pvx', mods)
  <div className={classes}>
    <h2 className='ui-toolbar-header pls'>{heading}</h2>
    <div className='ui-toolbar-controls by-right'>
      {# Layout Switcher: }
      <ButtonGroup mods='tertiary small right mls'>
        {layouts.map (btn)->
          mods = classList 'small', 'ui-toolbar-vis-button', btn.mods
          <Button {...btn} mods={mods} key={btn.mode}>
            <Icon i={btn.icon} title={btn.title}/>
          </Button>
        }
      </ButtonGroup>
      {# Action Buttons: }
      {if actions
        <ButtonGroup mods='small right mls'
          list={actions}/>}
    </div>
  </div>

UiPaginationNav = ({current, next, prev} = @props)->
  <ButtonGroup mods='mbm'>
    <Button {...prev} mods='mhn' disabled={not prev}>« Previous page</Button>
    <Button {...current} mods='mhn'>This Page</Button>
    <Button {...next} mods='mhn' disabled={not next}>Next page »</Button>
  </ButtonGroup>

FallBackMsg = ({children} = @props)->
  <div className='pvh mth mbl'>
    <div className='title-l by-center'>{children}</div>
  </div>

FilterPreloader = (
  <div className='ui-slide-filter-item'>
    <div className='title-xs by-center'>
      Filter werden geladen</div>
      <div className='ui-preloader small'></div>
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
