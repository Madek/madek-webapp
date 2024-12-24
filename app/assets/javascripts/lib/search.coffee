url = require('url')
f = require('active-lodash')
Bloodhound = require('@eins78/typeahead.js/dist/bloodhound.js').noConflict()
ui = require('../react/lib/ui.coffee')
t = ui.t

# NOTE: ignores RAILS_RELATIVE_URL_ROOT (this is OK given it runs on domain root)
resourcesConfig = # JSON API Endpoints:
  Users: { url: '/users', key: 'autocomplete_label', displayName: t('app_autocomplete_displayname_users') }
  Groups: { url: '/groups', key: 'detailed_name', params: ['scope'] }
  ApiClients: { url: '/api_clients', key: 'login' }
  People: { url: '/people', params: ['meta_key_id'] }
  Keywords: { url: '/keywords', key: 'label', params: ['meta_key_id'] }
  MetaKeys: { url: '/meta_keys', key: 'autocomplete_label' }
  Delegations: { url: '/delegations', key: 'autocomplete_label', displayName: t('app_autocomplete_displayname_delegations') }
  Roles: { url: '/roles', key: 'label', params: ['meta_key_id'] }

module.exports = (resourceType, parameters = null, localData)->
  unless (baseConfig = resourcesConfig[resourceType])?
    throw new Error "Search: Unknown resourceType: #{resourceType}!"
  missing = f.select(baseConfig.params, (key)-> f.isEmpty(parameters?[key]))
  unless f.isEmpty(missing)
    throw new Error "Search: #{resourceType}: missing parameters: #{missing}!"

  {
    name: "#{resourceType}Search",
    key: baseConfig.key or 'name',
    displayKey: baseConfig.displayKey or baseConfig.key or 'name',
    displayName: baseConfig.displayName,
    source: BloodhoundFactory(baseConfig, parameters, localData),
    limit: 100
  }

# helpers

tokenizer = (string)-> # trims leading and trailing whitespace
  Bloodhound.tokenizers.whitespace(f.trim(string))

langQueryParam = () ->
  f.pick(url.parse(location.href, true).query, 'lang')

BloodhoundFactory = (config, parameters, localData)->
  engine = new Bloodhound({
    datumTokenizer: tokenizer,
    queryTokenizer: tokenizer,
    local: localData,
    remote:
      wildcard: '__QUERY__'
      url: url.format
        pathname: config.url
        query: f.assign({search_term: '__QUERY__'}, parameters, langQueryParam())
  })

  # return *all* (possibly local) suggestions on empty query:
  return if !localData
    engine
  else
    (query, syncCallback, asyncCallback) ->
      if query == ''
        syncCallback(engine.all())
      else
        engine.search(query, syncCallback, asyncCallback)
