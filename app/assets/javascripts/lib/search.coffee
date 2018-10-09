url = require('url')
f = require('active-lodash')
Bloodhound = require('@eins78/typeahead.js/dist/bloodhound.js').noConflict()

# FIXME: ignores RAILS_RELATIVE_URL_ROOT
resourcesConfig = # JSON API Endpoints:
  Users: { url: '/users', key: 'autocomplete_label' }
  Groups: { url: '/groups', key: 'detailed_name', params: ['scope'] }
  ApiClients: { url: '/api_clients', key: 'login' }
  People: { url: '/people', params: ['meta_key_id'] }
  Roles: { url: '/roles' } #, params: ['meta_key_id'] }
  Keywords: { url: '/keywords', key: 'label', params: ['meta_key_id'] }

module.exports = (resourceType, parameters = null, localData)->
  unless (baseConfig = resourcesConfig[resourceType])?
    throw new Error "Search: Unknown resourceType: #{resourceType}!"
  missing = f.select(baseConfig.params, (key)-> f.isEmpty(parameters[key]))
  unless f.isEmpty(missing)
    throw new Error "Search: #{resourceType}: missing parameters: #{missing}!"

  {
    name: "#{resourceType}Search",
    key: baseConfig.key or 'name',
    displayKey: baseConfig.displayKey or baseConfig.key or 'name',
    source: BloodhoundFactory(baseConfig, parameters, localData),
    limit: 100
  }

# helpers

tokenizer = (string)-> # trims leading and trailing whitespace
  Bloodhound.tokenizers.whitespace(f.trim(string))

BloodhoundFactory = (config, parameters, localData)->
  engine = new Bloodhound({
    datumTokenizer: tokenizer,
    queryTokenizer: tokenizer,
    local: localData,
    remote:
      wildcard: '__QUERY__'
      url: url.format
        pathname: config.url
        query: f.assign({search_term: '__QUERY__'}, parameters)
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
