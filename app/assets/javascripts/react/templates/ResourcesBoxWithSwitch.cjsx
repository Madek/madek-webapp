# Box for search result pages, allows switching the *route*!

React = require('react')
f = require('active-lodash')
ui = require('../lib/ui.coffee')
t = ui.t
parseUrl = require('url').parse
stringifyUrl = require('url').format
parseQuery = require('qs').parse

Button = require('../ui-components/Button.cjsx')
ButtonGroup = require('../ui-components/ButtonGroup.cjsx')
ResourcesBox = require('../decorators/MediaResourcesBox.cjsx')
boxSetUrlParams = ResourcesBox.boxSetUrlParams

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

  forUrl: () ->
    @props.for_url

  render: (props = @props, state = @state)->
    {currentType, otherTypes} = props.switches
    types = f.flatten([currentType, otherTypes])

    renderSwitcher = (boxUrl) =>
      # NOTE: order of switches is defined here – should be consistent between views!
      typeBbtns = f.compact([
        {key: 'entries', name: t('sitemap_entries')},
        {key: 'sets', name: t('sitemap_collections')}])

      return (<ButtonGroup data-test-id='resource-type-switcher'>{typeBbtns.map (btn) =>
        return null unless f.include(types, btn.key) # only show mentioned types
        isActive = btn.key is currentType # set active is current type
        <Button {...btn}
          href={urlByType(boxUrl, currentType, btn.key)}
          mods={if isActive then 'active'}>
          {btn.name}
        </Button>}
      </ButtonGroup>)

    return (
      <ResourcesBox
        {...props}
        renderSwitcher={renderSwitcher}
      />
    )

urlByType = (url, currentType, newType) ->

  if currentType is newType then return url

  currentUrl = parseUrl(url)
  currentParams = parseQuery(currentUrl.query)

  newParams = f.cloneDeep(currentParams)
  if newParams.list

    if newParams.list.accordion
      newParams.list.accordion = {}

    if newParams.list.filter
      parsed = (try JSON.parse(newParams.list.filter))
      if parsed
        newParams.list.filter = JSON.stringify({search: parsed.search})
      else
        newParams.list.filter = JSON.stringify({})

    newParams.list.page = 1


  boxSetUrlParams(
    currentUrl.pathname.replace(RegExp("\/#{currentType}$"), "\/#{newType}"),
    newParams)
