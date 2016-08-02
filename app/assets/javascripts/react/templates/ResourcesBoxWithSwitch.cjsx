React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')
t = ui.t('de')
parseUrl = require('url').parse
parseQuery = require('qs').parse
setUrlParams = require('../../lib/set-params-for-url.coffee')

Button = require('../ui-components/Button.cjsx')
ButtonGroup = require('../ui-components/ButtonGroup.cjsx')
ResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
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

  componentDidMount: ()->
    router = require('../../lib/router.coffee')

    # listen to history and set state from params:
    @stopRouter = router.listen (location)=> @setState(url: location)
    # TMP: start the router (also immediatly calls listener(s) once if already attached!)
    router.start()

  componentWillUnmount: ()->
    if @stopRouter then @stopRouter()

  render: (props = @props)->
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
                onClick={@_onResourceSwitch}
                href={urlByType(props.for_url, currentType, btn.key)}
                mods={if isActive then 'active'}>
          {btn.name}
        </Button>}
      </ButtonGroup>)

    return (
      <ResourcesBox {...props}
        toolBarMiddle={resourceTypeSwitcher()}/>
    )

urlByType = (currentUrl, currentType, type)->
  if currentType is type then return currentUrl
  params = parseQuery(parseUrl(currentUrl).query)
  # NOTE: resetting all other 'list' params (pagination etc)
  resetlistParams = { list: { page: 1, filter: null } }
  parseQuery(parseUrl(currentUrl).query)
  # HACK: build link to 'sets', but remove filter (only 'search' is implemented!)
  searchTerm = (try JSON.parse(params.list.filter).search)
  listParams = if type is 'sets'
    { list: {
      accordion: null,
      filter: JSON.stringify({search: searchTerm}) } }

  # TODO: relative_url_root
  setUrlParams(
    currentUrl.replace("/#{currentType}", "/#{type}"),
    resetlistParams,
    listParams)
