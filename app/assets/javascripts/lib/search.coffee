Bloodhound = require('@eins78/typeahead.js/dist/bloodhound.js').noConflict()

config = # JSON API Endpoints:
  Person: { url: '/people' }

# TODO: memoize?
BloodhoundFactory = (config)->
  return unless config?
  new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: config.url + '.json?search_term=%QUERY'
      wildcard: '%QUERY'

module.exports = (resourceType = null)->
  BloodhoundFactory(config[resourceType]) if config[resourceType]?
