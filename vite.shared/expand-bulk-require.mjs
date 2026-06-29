/**
 * expand-bulk-require.mjs
 *
 * Helper to expand bulk-require calls into a nested object of require() calls.
 * Used by the source transform plugin for both client and server builds.
 */

import { basename, extname } from 'path'
import fg from 'fast-glob'

const { sync: globSync } = fg

/**
 * Expands a bulk-require call into a nested object of require() calls.
 *
 * @param {string} dir - The directory to resolve patterns from
 * @param {string[]} patterns - Glob patterns to match files
 * @returns {string} - Serialized JavaScript code representing the nested require object
 */
export function expandBulkRequire(dir, patterns) {
  const seen = new Set()
  const root = {}

  for (const pattern of patterns) {
    const files = globSync(pattern, { cwd: dir })
    for (const file of files) {
      if (seen.has(file)) continue
      seen.add(file)

      const parts = file.replace(/^\.\//, '').split('/')
      const len = parts.length
      parts[len - 1] = basename(parts[len - 1], extname(parts[len - 1]))

      let current = root
      for (let i = 0; i < parts.length - 1; i++) {
        if (!current[parts[i]]) current[parts[i]] = {}
        current = current[parts[i]]
      }
      current[parts[len - 1]] = './' + file.replace(/^\.\//, '')
    }
  }

  function serialize(obj) {
    if (typeof obj === 'string') {
      // Wrap require in a helper that extracts .default for ESM interop.
      // When a file uses `export default X`, esbuild's CJS output wraps it as
      // { default: X, __esModule: true }. This helper unwraps it automatically.
      return `(function(m) { return m && m.__esModule ? m.default : m; })(require(${JSON.stringify(obj)}))`
    }
    const entries = Object.entries(obj).map(([k, v]) => `${JSON.stringify(k)}: ${serialize(v)}`)
    return `({ ${entries.join(', ')} })`
  }

  return serialize(root)
}
