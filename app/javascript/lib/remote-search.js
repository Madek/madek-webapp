/**
 * remote-search.js
 *
 * Lightweight replacement for the Bloodhound data engine from typeahead.js.
 * Provides the same (query, syncCallback, asyncCallback) source interface
 * that TypeaheadInput expects, with:
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
 * @param {function} [options.transform] - Transform the raw JSON response array
 * @param {function} [options.prepare]   - (query, url) => url; for custom URL building
 * @returns {function} source(query, syncCallback, asyncCallback)
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
    const items = transform(Array.isArray(json) ? json : json.results || json.data || [])
    cache.set(url, items)
    return items
  }

  return function source(query, syncCallback, asyncCallback) {
    // Empty query: return all local items synchronously if available
    if (!query && local) {
      syncCallback(local)
      return
    }

    // Debounce the remote fetch
    if (debounceTimer) clearTimeout(debounceTimer)
    debounceTimer = setTimeout(async () => {
      try {
        const items = await fetchItems(query || '')
        asyncCallback(items)
      } catch (err) {
        // eslint-disable-next-line no-console
        console.error('[remote-search] fetch error:', err)
        asyncCallback([])
      }
    }, DEBOUNCE_MS)
  }
}

/**
 * Whitespace tokenizer — same interface as Bloodhound.tokenizers.whitespace.
 * Splits a string on whitespace and filters empty tokens.
 */
export function whitespaceTokenizer(str) {
  if (!str) return []
  return str.trim().split(/\s+/).filter(Boolean)
}

/**
 * Creates a source function backed by a local array only (no remote fetch).
 * Filters items by matching the query against tokenized fields.
 *
 * @param {Array}  items     - The local data array
 * @param {string|function} keyField - Field name to match against, or a function (item) => string
 * @returns {function} source(query, syncCallback, asyncCallback)
 */
export function createLocalSource(items, keyField = 'label') {
  const getValue = typeof keyField === 'function' ? keyField : item => item[keyField] || ''

  return function source(query, syncCallback) {
    if (!query) {
      syncCallback(items)
      return
    }
    const q = query.toLowerCase()
    syncCallback(items.filter(item => getValue(item).toLowerCase().includes(q)))
  }
}
