url = require('url')
f = require('active-lodash')
Bloodhound = require('@eins78/typeahead.js/dist/bloodhound.js').noConflict()

resourcesConfig = # JSON API Endpoints:
  Users: { url: '/users' }
  Groups: { url: '/my/groups' }
  ApiClients: { url: '/api_clients', key: 'login' }
  People: { url: '/people' }
  Keywords: { url: '/keywords', key: 'term', params: ['meta_key_id'] }

module.exports = (resourceType, parameters = null)->
  unless (baseConfig = resourcesConfig[resourceType])?
    throw new Error "Search: Unknown resourceType: #{resourceType}!"
  missing = f.select(baseConfig.params, (key)-> f.isEmpty(parameters[key]))
  unless f.isEmpty(missing)
    throw new Error "Search: #{resourceType}: missing parameters: #{missing}!"

  {
    name: "#{resourceType}Search",
    key: baseConfig.key or 'name',
    displayKey: baseConfig.displayKey or baseConfig.key or 'name',
    source: BloodhoundFactory(baseConfig, parameters)
  }

# helpers

tokenizer = (string)-> # trims leading and trailing whitespace
  Bloodhound.tokenizers.whitespace(f.trim(string))

# TODO: memoize?
BloodhoundFactory = (config, parameters = null)->
  new Bloodhound
    datumTokenizer: tokenizer
    queryTokenizer: tokenizer
    remote:
      wildcard: '__QUERY__'
      url: url.format
        pathname: config.url
        query: f.assign({search_term: '__QUERY__'}, parameters)
