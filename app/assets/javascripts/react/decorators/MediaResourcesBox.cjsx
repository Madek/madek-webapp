React = require('react')
f = require('active-lodash')
classList = require('classnames')
qs = require('qs')
ampersandReactMixin = require('ampersand-react-mixin')
setUrlParams = require('../../lib/set-params-for-url.coffee')
resourceListParams = require('../../shared/resource_list_params.coffee')
RailsForm = require('../lib/forms/rails-form.cjsx')
{ Button, ButtonGroup, Icon, Link, ActionsBar, FilterBar
} = require('../ui-components/index.coffee')
ResourceThumbnail = require('./ResourceThumbnail.cjsx')
router = null # client-side only

# TOOD: i18n

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
  filter: filterConfigProps
  layout: React.PropTypes.oneOf(['tiles', 'miniature', 'grid', 'list'])
  show_filter: React.PropTypes.bool
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
    interactive: React.PropTypes.bool # toggles simple list or full box
    initial: viewConfigProps
    get: React.PropTypes.shape
      config: viewConfigProps

  # kick of client-side mode:
  getInitialState: ()-> {active: false, config: {}}
  getObservedItems: ()-> [f.get(@props, ['get', 'resources'])]
  componentDidMount: ()->
    router = require('../../lib/router.coffee')

    @setState(active: true, selected: [])

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
    handleLinkIfLocal event, (link)->


  render: ({get, mods, interactive, initial} = @props)->
    get = f.defaultsDeep \      # combine config in order:
      {config: @state.config},  # - client-side state
      get,                      # - presenter & config (from params)
      {config: initial},        # - per-view initial default config
      config:                   # - default config
        layout: 'grid'
        show_filter: true

    relevantQuery = f.merge \
      {list: f.merge f.omit(get.config, 'for_url')},
      {list: filter: JSON.stringify(get.config.filter)}

    boxClasses = classList 'ui-container', mods,
      'midtone': interactive
      'bordered': interactive

    listHolderClasses = classList 'ui-resources-holder',
      pam: interactive

    listClasses = classList 'ui-resources', get.config.layout,
      active: interactive
      vertical: get.config.layout is 'tiles'

    BoxToolBar = if interactive then do ({for_url, layout} = get.config)=>
      layouts = LAYOUT_MODES.map (itm)=>
        href = setUrlParams(for_url, relevantQuery, list: layout: itm.mode)
        f.merge itm,
          mods: active: layout is itm.mode
          href: href
          onClick: @handleChangeInternally
      <UiToolBar layouts={layouts}/>

    BoxFilterBar = if interactive then do ({config} = get)=>
      filterToggleLink = setUrlParams(config.for_url, relevantQuery,
        list: show_filter: (not config.show_filter))
      resetFilterLink = setUrlParams(
        config.for_url, relevantQuery, list: filter: '{}')
      props =
        filter:
          toggle:
            name: 'Filtern'
            mods: 'active' if config.show_filter
            href: filterToggleLink
            onClick: @handleChangeInternally
          reset: if f.present(config.filter)
            name: 'Filter zurücksetzen'
            href: resetFilterLink
        # toggles: [
        #   {name: 'Medieneinträge'},
        #   {name: 'Sets'} ]
        # select:
        #   active: 'Alle abwählen',
        #   inactive: 'Alle auswählen'
        #   isActive: f.any?(get.config.selected)
        #   onClick: @handleSelectionToggle
      <FilterBar {...props}/>

    Sidebar = if interactive and get.config.show_filter then do ({config} = get)->
      <div className='filter-panel ui-side-filter'>
        <UiSideFilter {...config}/>
        <TmpFilterExamples examples={_tmp_filter_examples}
          url={config.for_url} query={relevantQuery}/>
      </div>

    paginationNav = if interactive then do ({config, pagination} = get)=>
      navLinks =
        current:
          href: setUrlParams(get.config.for_url, relevantQuery)
          onClick: @handleChangeInternally
        prev: if pagination.prev
          href: setUrlParams(config.for_url, relevantQuery, list: pagination.prev)
        next: if pagination.next
          href: setUrlParams(config.for_url, relevantQuery, list: pagination.next)
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
              <FallBackMsg>{'Keine Inhalte verfügbar'}</FallBackMsg>
            else
              <ul className={listClasses}>
                {get.resources.map (item)->
                  key = item.uuid or item.cid
                  <ResourceThumbnail elm='li' get={item} key={key}/>}
              </ul>
            }
            {paginationNav}
          </div>

        </div>
      </div>

    </div>

# Partials and UI-Components only used here:

UiSideFilter = ({filter} = @props)->
  <div className='ui-side-filter-search filter-search'>
    <RailsForm name='list' method='get' mods='prm'>
      <textarea name='list[filter]' rows='25'
        style={{fontFamily: 'monospace', fontSize: '1em', width: '100%'}}
        defaultValue={JSON.stringify(filter, 0, 2)}/>
      <Button type='submit'>Submit</Button>
    </RailsForm>
  </div>

UiToolBar = ({layouts} = @props)->
  <div className='ui-container inverted ui-toolbar pvx'>
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


TmpFilterExamples = ({url, query, examples} = @props)->
  <div>
    <h4>[TMP] examples:</h4>
    <ul>
      {f.map examples, (example, name)->
        params = {list: {page: 1, filter: JSON.stringify(example, 0, 2)}}
        <li key={name}>
          <Link href={setUrlParams(url, query, params)}>{name}</Link>
        </li>
      }
    </ul>
  </div>

# TMP
_tmp_filter_examples = {
  "Search: 'still'": {
    "search": "still"
  },
  "Title: 'diplom'": {
    "meta_data": [{ "key": "madek_core:title", "match": "diplom" }]
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
