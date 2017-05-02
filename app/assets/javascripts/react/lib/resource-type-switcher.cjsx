React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
parseUrl = require('url').parse
stringifyUrl = require('url').format
parseQuery = require('qs').parse
t = require('../../lib/string-translation.js')('de')
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

  return (<ButtonGroup>{typeBbtns.map (btn) =>
    isCurrent = currentType == btn.key
    isDefault = if !currentType
      if showAll
        btn.key == 'all'
      else
        btn.key == 'entries'
    isActive = isCurrent || isDefault

    btnUrl = setUrlParams(forUrl, {type: btn.key})

    <Button {...btn}
      onClick={onClick}
      href={btnUrl}
      mods={if isActive then 'active'}>
      {btn.name}
    </Button>}
  </ButtonGroup>)
