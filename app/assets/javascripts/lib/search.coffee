Bloodhound = require('@eins78/typeahead.js/dist/bloodhound.js').noConflict()

resourcesConfig = # JSON API Endpoints:
  Person: { url: '/people' }
  User: { url: '/users' }
  Group: { url: '/my/groups' }
  ApiClient: { url: '/api_clients', key: 'login' }

# TODO: memoize?
BloodhoundFactory = (config)->
  new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: config.url + '.json?search_term=%QUERY'
      wildcard: '%QUERY'

module.exports = (resourceType = null)->
  if (config = resourcesConfig[resourceType])?
    {
      name: "#{resourceType}Search",
      key: config.key or 'name',
      displayKey: config.displayKey or config.key or 'name',
      source: BloodhoundFactory(config)
    }
