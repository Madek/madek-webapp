url = require('url')
f = require('active-lodash')
Bloodhound = require('@eins78/typeahead.js/dist/bloodhound.js').noConflict()

resourcesConfig = # JSON API Endpoints:
  Users: { url: '/users' }
  Groups: { url: '/my/groups' }
  ApiClients: { url: '/api_clients', key: 'login' }
  People: { url: '/people' }
  Keywords: { url: '/keywords', key: 'term', params: ['meta_key_id'] }

# TODO: memoize?
BloodhoundFactory = (config, parameters = null)->
  new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      wildcard: '__QUERY__'
      url: url.format
        pathname: config.url
        query: f.assign({search_term: '__QUERY__'}, parameters)


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
