import url from 'url'
import f from 'active-lodash'
import { t } from '../react/lib/ui.js'
import { createRemoteSource } from './remote-search.js'

// NOTE: ignores RAILS_RELATIVE_URL_ROOT (this is OK given it runs on domain root)
const resourcesConfig = {
  // JSON API Endpoints:
  Users: {
    url: '/users',
    key: 'autocomplete_label',
    displayName: t('app_autocomplete_displayname_users')
  },
  Groups: { url: '/groups', key: 'detailed_name', params: ['scope'] },
  ApiClients: { url: '/api_clients', key: 'login' },
  People: { url: '/people', params: ['meta_key_id'] },
  Keywords: { url: '/keywords', key: 'label', params: ['meta_key_id'] },
  MetaKeys: { url: '/meta_keys', key: 'autocomplete_label' },
  Delegations: {
    url: '/delegations',
    key: 'autocomplete_label',
    displayName: t('app_autocomplete_displayname_delegations')
  },
  Roles: { url: '/roles', key: 'label', params: ['meta_key_id'] }
}

const langQueryParam = () => f.pick(url.parse(location.href, true).query, 'lang')

module.exports = function (resourceType, parameters = null, localData) {
  let baseConfig
  if ((baseConfig = resourcesConfig[resourceType]) == null) {
    throw new Error(`Search: Unknown resourceType: ${resourceType}!`)
  }
  const missing = f.select(baseConfig.params, key =>
    f.isEmpty(parameters != null ? parameters[key] : undefined)
  )
  if (!f.isEmpty(missing)) {
    throw new Error(`Search: ${resourceType}: missing parameters: ${missing}!`)
  }

  const searchUrl = url.format({
    pathname: baseConfig.url,
    query: f.assign({ search_term: '__QUERY__' }, parameters, langQueryParam())
  })

  const source = createRemoteSource(searchUrl, {
    local: localData || null,
    wildcard: '__QUERY__'
  })

  return {
    name: `${resourceType}Search`,
    key: baseConfig.key || 'name',
    displayKey: baseConfig.displayKey || baseConfig.key || 'name',
    displayName: baseConfig.displayName,
    source,
    limit: 100
  }
}
