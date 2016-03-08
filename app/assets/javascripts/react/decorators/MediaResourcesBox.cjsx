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
router = null # client-side only

xhr = require('xhr')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')

# Props/Config overview:
# - props.interactive = should the UI offer any interaction
# - state.active = is component in client-side mode
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
  show_filter: React.PropTypes.bool # shows SideFilter (when interactive)
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
  mixins: [ampersandReactMixin]
  propTypes:
    initial: viewConfigProps
    interactive: React.PropTypes.bool.isRequired # toggles simple list or full box
    get: React.PropTypes.shape
      resources: React.PropTypes.array.isRequired
      can_filter: React.PropTypes.bool.isRequired # if true, get.resources can be filtered
      config: viewConfigProps # <- config that is part of the URL!
      dynamic_filters: React.PropTypes.array.isRequired

  # kick of client-side mode:
  getInitialState: ()-> {active: false, config: {}}
  getObservedItems: ()-> [f.get(@props, ['get', 'resources'])]
  componentDidMount: ()->
    router = require('../../lib/router.coffee')

    @setState(active: yes, showDynFilters: yes)

    # listen to history and set state from params:
    router.listen (location)=>
      @setState(config: f.merge(@state.config, resourceListParams(location)))

    # start the router (also immediatly calls listener once)
    router.start()

  # client-side link handlers:
  # - for state changes that don't need new data (like visual changes):
  handleChangeInternally: (event)->
    handleLinkIfLocal(event, router.goTo)

  # - for state changes that update the resources (like filter):
  handleRequestInternally: (event)->
    handleLinkIfLocal(event, alert)

  # - custom actions:
  handleDynamicFilterToggle: (bool, event)->
    event.preventDefault()
    @setState(showDynFilters: bool)

  handleAccordion: (event)->
    parameters = list:
      page: 1 # make sure that the new result starts on page 1
      filter: JSON.stringify(event.current)
      accordion: JSON.stringify(event.accordion)
    newUrl = setUrlParams(@props.for_url, parameters)
    window.location = newUrl

    # @handleChangeInternally(event)
    # console.log 'handleAccordion', arguments
    # # handleLinkIfLocal(event, …)
    # console.log 'handleAccordion', config, f.get(event, ['target', 'value'])
    # event.preventDefault()
    # @setState(dynamicFilters: config)

  createFilterSetFromConfig: (config, event)->
    event.preventDefault()
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


  render: ({get, mods, initial, interactive, saveable, authToken} = @props)->

    get = f.defaultsDeep \      # combine config in order:
      {config: @state.config},  # - client-side state
      get,                      # - presenter & config (from params)
      {config: initial},        # - per-view initial default config
      config:                   # - default config
        layout: 'grid'
        show_filter: false
        dyn_filter: {}

    # console.log 'MediaResourcesBox: get, initial', get, initial

    config = get.config

    boxClasses = classList({ # defaults first, mods last so they can override
      'ui-container': yes
      'midtone': interactive
      'bordered': interactive
    }, mods)

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
      pam: interactive

    listClasses = classList 'ui-resources', config.layout,
      active: interactive
      vertical: config.layout is 'tiles'

    currentQuery = f.merge(
      {list: f.merge f.omit(config, 'for_url')},
      {
        list: filter: JSON.stringify(config.filter),
        accordion: JSON.stringify(config.accordion)
      })

    resetFilterHref =
      setUrlParams(config.for_url, currentQuery, list:
        page: 1, filter: {}, accordion: {})

    resetFilterLink = if resetFilterHref
      if f.present(config.filter) or f.present(config.accordion)
        <Link mods='mlx weak' href={resetFilterHref}>
          <Icon i='undo'/> {'Filter zurücksetzen'}</Link>

    BoxToolBar = if interactive then do ({for_url, layout} = config)=>
      layouts = LAYOUT_MODES.map (itm)=>
        href = setUrlParams(for_url, currentQuery, list: layout: itm.mode)
        f.merge itm,
          mods: active: layout is itm.mode
          href: href
          onClick: @handleChangeInternally
      actions =
        save: if saveable and @state.active # FIXME: <- HACK, no fallback
          children: 'Save!'
          onClick: f.curry(@createFilterSetFromConfig)(config)

      <UiToolBar mods={toolbarClasses} actions={actions} layouts={layouts}/>

    BoxFilterBar = do ->
      # NOTE: don't show the bar at all if no 'filter' button!
      return null if (!interactive or !get.can_filter)

      filterToggleLink = setUrlParams(config.for_url, currentQuery,
        list: show_filter: (not config.show_filter))

      props =
        filter:
          toggle:
            name: 'Filtern'
            mods: 'active' if config.show_filter
            href: filterToggleLink
            # onClick: @handleChangeInternally
          reset: resetFilterLink if not config.show_filter

        # TODO: multi resource switcher
        # toggles: [
        #   {name: 'Medieneinträge'},
        #   {name: 'Sets'} ]
        # select:
        #   active: 'Alle abwählen',
        #   inactive: 'Alle auswählen'
        #   isActive: f.any?(get.config.selected)
        #   onClick: @handleSelectionToggle

      <FilterBar {...props}/>

    Sidebar = do ({config, dynamic_filters} = get, {active, showDynFilters} = @state)=>
      # TMP: ignore invalid dynamicFilters
      if !(f.isArray(dynamic_filters) and f.present(f.isArray(dynamic_filters)))
        return null

      dynToggleBtn = if active
        <Button
          title={if showDynFilters then 'off' else 'on'}
          mods={'active' if showDynFilters}
          onClick={f.curry(@handleDynamicFilterToggle)(!showDynFilters)}>
          <Icon i='eye'/></Button>
      else
        <Button><Icon i='eye'/></Button>

      <div className='filter-panel ui-side-filter'>
        <ButtonGroup  mod='tertiary' mods='small by-right mbs ui-side-filter-toolbar'>
          {dynToggleBtn}
          <Button title='Open all' href={null}><Icon i='arrow-up'/></Button>
          <Button title='Reset All Filters'
            href={resetFilterHref if resetFilterLink}>
            <Icon i='undo'/></Button>
        </ButtonGroup>

        {if not showDynFilters
          <div>
            <SideFilterFallback {...config}/>
            <FilterExamples examples={filter_examples}
              url={config.for_url} query={currentQuery}/>
          </div>
        else
          <SideFilter dynamic={dynamic_filters} current={config.filter or {}}
            accordion={config.accordion or {}} onChange={@handleAccordion}
            url={config.for_url} query={currentQuery}/>
        }
      </div>

    paginationNav = if interactive then do ({config, pagination} = get)=>
      navLinks =
        current:
          href: setUrlParams(config.for_url, currentQuery)
          onClick: @handleChangeInternally
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
                {get.resources.map (item)->
                  key = item.uuid or item.cid
                  <ResourceThumbnail elm='li' get={item} key={key} authToken={authToken} />}
              </ul>
            }
            {paginationNav}
          </div>

        </div>
      </div>

    </div>

# Partials and UI-Components only used here:

SideFilterFallback = ({filter} = @props)->
  <div className='ui-side-filter-search filter-search'>
    <RailsForm name='list' method='get' mods='prm'>
      <textarea name='list[filter]' rows='25'
        style={{fontFamily: 'monospace', fontSize: '1em', width: '100%'}}
        defaultValue={JSON.stringify(filter, 0, 2)}/>
      <Button type='submit'>Submit</Button>
    </RailsForm>
  </div>

UiToolBar = ({mods, layouts, actions} = @props)->
  classes = classList('ui-container inverted ui-toolbar pvx', mods)
  <div className={classes}>
    {### TODO: type + counts?
      <h2 className='ui-toolbar-header pls'>
        {'X Resources'}
      </h2>
    ###}
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
      {if f.any(actions) then <ButtonGroup mods='tertiary small right mls'>
        {f.map actions, (btn, id)-> <Button {...btn} key={id}/>}
      </ButtonGroup>}
    </div>
  </div>

UiPaginationNav = ({current, next, prev} = @props)->
  <ButtonGroup mods='mbm'>
    <Button {...prev} mods='mhn' disabled={not prev}>« Previous page</Button>
    <Button {...current} mods='mhn'>This Page</Button>
    <Button {...next} mods='mhn' disabled={not next}>Next page »</Button>
  </ButtonGroup>

# TODO: also show a reset filter link if active filter
FallBackMsg = ({children} = @props)->
  <div className='pvh mth mbl'>
    <div className='title-l by-center'>{children}</div>
  </div>


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
