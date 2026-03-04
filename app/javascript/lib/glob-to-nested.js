/**
 * Convert flat import.meta.glob results to a nested object structure.
 *
 * import.meta.glob returns: { './My/Uploader.jsx': Module, './My/Settings.jsx': Module }
 * bulk-require returned:    { My: { Uploader: Component, Settings: Component } }
 *
 * This function bridges the two formats.
 *
 * @param {Object} modules - Result of import.meta.glob with { eager: true }
 * @param {string} stripPrefix - Prefix to remove from keys (e.g., './' or './decorators/')
 * @returns {Object} Nested object matching bulk-require's output structure
 */
export function globToNested(modules, stripPrefix = './') {
  const result = {}

  for (const [path, mod] of Object.entries(modules)) {
    // Strip prefix and file extension
    let cleanPath = path
    if (stripPrefix && cleanPath.startsWith(stripPrefix)) {
      cleanPath = cleanPath.slice(stripPrefix.length)
    }
    cleanPath = cleanPath.replace(/\.\w+$/, '') // remove .jsx, .js, etc.

    // Skip index files (they are the aggregator files themselves)
    const filename = cleanPath.split('/').pop()
    if (filename === 'index') continue

    // Split into path segments
    const segments = cleanPath.split('/')

    // Build nested object
    let current = result
    for (let i = 0; i < segments.length - 1; i++) {
      if (!current[segments[i]]) {
        current[segments[i]] = {}
      }
      current = current[segments[i]]
    }

    // Set the leaf value
    // Prefer default export, fall back to the module object itself
    const leafKey = segments[segments.length - 1]
    const value = mod.default !== undefined ? mod.default : mod

    // If the key already exists as an object (from a subdirectory),
    // and the new value is a function/component, merge them
    if (current[leafKey] && typeof current[leafKey] === 'object' && typeof value === 'function') {
      Object.assign(value, current[leafKey])
    }
    current[leafKey] = value
  }

  return result
}

/**
 * Flat version: strips paths, returns { Filename: Component }
 * Used for single-level directories (e.g., ui-components/*.jsx)
 */
export function globToFlat(modules, stripPrefix = './') {
  const result = {}
  for (const [path, mod] of Object.entries(modules)) {
    let cleanPath = path
    if (stripPrefix && cleanPath.startsWith(stripPrefix)) {
      cleanPath = cleanPath.slice(stripPrefix.length)
    }
    cleanPath = cleanPath.replace(/\.\w+$/, '')
    if (cleanPath === 'index') continue

    result[cleanPath] = mod.default !== undefined ? mod.default : mod
  }
  return result
}
