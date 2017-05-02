# Box for search result pages, allows switching the *route*!

React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')
t = ui.t('de')
parseUrl = require('url').parse
stringifyUrl = require('url').format
parseQuery = require('qs').parse

Button = require('../ui-components/Button.cjsx')
ButtonGroup = require('../ui-components/ButtonGroup.cjsx')
ResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
boxSetUrlParams = ResourcesBox.boxSetUrlParams

# client-side only
router = null

TYPES = ['entries', 'sets'] # see `typeBbtns`, types are defined there

module.exports = React.createClass
  displayName: 'ResourcesBoxWithSwitch'
  propTypes:
    switches: React.PropTypes.shape({
      currentType: React.PropTypes.oneOf(TYPES)
      otherTypes: React.PropTypes.arrayOf(React.PropTypes.oneOf(TYPES))
    })
    for_url: React.PropTypes.string.isRequired
    # all other props are just passed through to ResourcesBox:
    get: React.PropTypes.object.isRequired

  getInitialState: ()-> { url: @props.for_url }

  componentDidMount: ()->
    router = require('../../lib/router.coffee')

    # listen to history and set state from params:
    @stopRouter = router.listen (location)=> @setState(url: stringifyUrl(location))
    # TMP: start the router (also immediatly calls listener(s) once if already attached!)
    router.start()

  componentWillUnmount: ()->
    if @stopRouter then @stopRouter()

  render: (props = @props, state = @state)->
    {currentType, otherTypes} = props.switches
    types = f.flatten([currentType, otherTypes])

    resourceTypeSwitcher = () =>
      # NOTE: order of switches is defined here – should be consistent between views!
      typeBbtns = f.compact([
        {key: 'entries', name: t('sitemap_entries')},
        {key: 'sets', name: t('sitemap_collections')}])

      return (<ButtonGroup>{typeBbtns.map (btn) =>
        return null unless f.include(types, btn.key) # only show mentioned types
        isActive = btn.key is currentType # set active is current type
        <Button {...btn}
          href={urlByType(state.url, currentType, btn.key)}
          mods={if isActive then 'active'}>
          {btn.name}
        </Button>}
      </ButtonGroup>)

    return (
      <ResourcesBox {...props}
        toolBarMiddle={resourceTypeSwitcher()}/>
    )

urlByType = (url, currentType, type)->
  if currentType is type then return url

  currentUrl = parseUrl(url)
  currentParams = parseQuery(currentUrl.query)

  # NOTE: resetting all other 'list' params (pagination etc)
  resetlistParams = { page: 1, accordion: null }

  # HACK: build link to 'sets', but remove filter (only 'search' is implemented!)
  searchTerm = (try JSON.parse(currentParams.list.filter).search)

  listParams = f.assign(currentParams.list, resetlistParams)
  if type is 'sets'
    listParams = f.assign(listParams, { filter: JSON.stringify({search: searchTerm}) })

  boxSetUrlParams(
    currentUrl.pathname.replace(RegExp("\/#{currentType}$"), "\/#{type}"),
    f.omit(currentParams, 'list'), {list: listParams})
