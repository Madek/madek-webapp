/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const url = require('url');
const f = require('active-lodash');
const Bloodhound = require('@eins78/typeahead.js/dist/bloodhound.js').noConflict();
const ui = require('../react/lib/ui.coffee');
const {
  t
} = ui;

// NOTE: ignores RAILS_RELATIVE_URL_ROOT (this is OK given it runs on domain root)
const resourcesConfig = { // JSON API Endpoints:
  Users: { url: '/users', key: 'autocomplete_label', displayName: t('app_autocomplete_displayname_users') },
  Groups: { url: '/groups', key: 'detailed_name', params: ['scope'] },
  ApiClients: { url: '/api_clients', key: 'login' },
  People: { url: '/people', params: ['meta_key_id'] },
  Keywords: { url: '/keywords', key: 'label', params: ['meta_key_id'] },
  MetaKeys: { url: '/meta_keys', key: 'autocomplete_label' },
  Delegations: { url: '/delegations', key: 'autocomplete_label', displayName: t('app_autocomplete_displayname_delegations') },
  Roles: { url: '/roles', key: 'label', params: ['meta_key_id'] }
};

module.exports = function(resourceType, parameters = null, localData){
  let baseConfig;
  if ((baseConfig = resourcesConfig[resourceType]) == null) {
    throw new Error(`Search: Unknown resourceType: ${resourceType}!`);
  }
  const missing = f.select(baseConfig.params, key => f.isEmpty(parameters != null ? parameters[key] : undefined));
  if (!f.isEmpty(missing)) {
    throw new Error(`Search: ${resourceType}: missing parameters: ${missing}!`);
  }

  return {
    name: `${resourceType}Search`,
    key: baseConfig.key || 'name',
    displayKey: baseConfig.displayKey || baseConfig.key || 'name',
    displayName: baseConfig.displayName,
    source: BloodhoundFactory(baseConfig, parameters, localData),
    limit: 100
  };
};

// helpers

const tokenizer = string => // trims leading and trailing whitespace
Bloodhound.tokenizers.whitespace(f.trim(string));

const langQueryParam = () => f.pick(url.parse(location.href, true).query, 'lang');

var BloodhoundFactory = function(config, parameters, localData){
  const engine = new Bloodhound({
    datumTokenizer: tokenizer,
    queryTokenizer: tokenizer,
    local: localData,
    remote: {
      wildcard: '__QUERY__',
      url: url.format({
        pathname: config.url,
        query: f.assign({search_term: '__QUERY__'}, parameters, langQueryParam())
      })
    }
  });

  // return *all* (possibly local) suggestions on empty query:
  if (!localData) {
    return engine;
  } else {
    return function(query, syncCallback, asyncCallback) {
      if (query === '') {
        return syncCallback(engine.all());
      } else {
        return engine.search(query, syncCallback, asyncCallback);
      }
    };
  }
};
