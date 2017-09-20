React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
parseUrl = require('url').parse
stringifyUrl = require('url').format
parseQuery = require('qs').parse
t = require('../../lib/i18n-translate.js')
setUrlParams = require('../../lib/set-params-for-url.coffee')
libUrl = require('url')
qs = require('qs')
Button = require('../ui-components/Button.cjsx')
ButtonGroup = require('../ui-components/ButtonGroup.cjsx')

module.exports = (resources, forUrl, showAll, onClick) ->
  listConfig = resources.config
  currentType = qs.parse(libUrl.parse(forUrl).query).type
  typeBbtns = f.compact([
    {key: 'all', name: 'Alle'} if showAll,
    {key: 'entries', name: t('sitemap_entries')},
    {key: 'collections', name: t('sitemap_collections')}])

  return (<ButtonGroup data-test-id='resource-type-switcher'>{typeBbtns.map (btn) =>
    isCurrent = currentType == btn.key
    isDefault = if !currentType
      if showAll
        btn.key == 'all'
      else
        btn.key == 'entries'
    isActive = isCurrent || isDefault

    btnUrl = urlByType(forUrl, currentType, btn.key)

    <Button {...btn}
      onClick={onClick}
      href={btnUrl}
      mods={if isActive then 'active'}>
      {btn.name}
    </Button>}
  </ButtonGroup>)


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


  setUrlParams(
    currentUrl,
    {list: newParams.list},
    {type: newType}
  )
