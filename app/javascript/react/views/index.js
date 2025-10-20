// Use webpack's require.context instead of bulk-require
const context = require.context('./', true, /\.jsx$/)
const result = { views: {} }

context.keys().forEach(key => {
  // Parse the path: ./Something.jsx or ./Folder/Something.jsx
  const parts = key
    .replace(/^\.\//, '')
    .replace(/\.jsx$/, '')
    .split('/')

  if (parts.length === 1) {
    // Top-level file: ./Something.jsx -> views.Something
    result.views[parts[0]] = context(key).default || context(key)
  } else {
    // Nested file: ./Folder/Something.jsx -> views.Folder.Something
    let current = result.views
    for (let i = 0; i < parts.length - 1; i++) {
      if (!current[parts[i]]) {
        current[parts[i]] = {}
      }
      current = current[parts[i]]
    }
    current[parts[parts.length - 1]] = context(key).default || context(key)
  }
})

module.exports = result
