/**
 * remote-search.js
 *
 *  - debounced remote fetch
 *  - simple in-memory response cache (per URL)
 *  - optional local (pre-loaded) data searched synchronously on empty query
 */

const DEBOUNCE_MS = 200

/**
 * Creates a source function for a remote endpoint.
 *
 * @param {string} urlTemplate  - URL with `__QUERY__` as the wildcard placeholder
 * @param {object} [options]
 * @param {Array}  [options.local]     - Pre-loaded items returned on empty query
 * @param {string} [options.wildcard]  - Placeholder string in urlTemplate (default: '__QUERY__')
 * @param {function} [options.transform] - Transform the raw JSON response before the default extraction
 *                                         mechanisms is applied (json-when-array || json.results || json.data)
 * @param {function} [options.prepare]   - (query, url) => url; for custom URL building
 * @returns {function} source(query, callback)
 */
export function createRemoteSource(urlTemplate, options = {}) {
  const {
    local = null,
    wildcard = '__QUERY__',
    transform = items => items,
    prepare = null
  } = options

  const cache = new Map()
  let debounceTimer = null

  function buildUrl(query) {
    if (prepare) return prepare(query, urlTemplate)
    return urlTemplate.replace(wildcard, encodeURIComponent(query))
  }

  async function fetchItems(query) {
    const url = buildUrl(query)
    if (cache.has(url)) return cache.get(url)

    const response = await fetch(url, {
      headers: { Accept: 'application/json' },
      credentials: 'same-origin'
    })
    if (!response.ok) throw new Error(`Search fetch failed: ${response.status}`)
    const json = await response.json()
    const data = transform(json)
    const items = Array.isArray(data) ? data : data.results || data.data || []
    cache.set(url, items)
    return items
  }

  return function source(query, callback) {
    // Empty query: return all local items synchronously if available
    if (!query && local) {
      callback(local)
      return
    }

    // Debounce the remote fetch
    if (debounceTimer) clearTimeout(debounceTimer)
    debounceTimer = setTimeout(async () => {
      try {
        const items = await fetchItems(query || '')
        callback(items)
      } catch (err) {
        // eslint-disable-next-line no-console
        console.error('[remote-search] fetch error:', err)
        callback([])
      }
    }, DEBOUNCE_MS)
  }
}
