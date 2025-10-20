# Migration from Browserify to Webpack

This document describes the migration from Browserify to Webpack 5.

## Changes Made

### 1. Build Configuration

- **Created `webpack.config.js`**: Main webpack configuration file
  - Configured 4 entry points matching the original setup:
    - `bundle.js` (main application)
    - `bundle-embedded-view.js` (embedded views)
    - `bundle-react-server-side.js` (server-side rendering)
    - `bundle-integration-testbed.js` (integration tests)
  - Outputs to `public/assets/bundles/` as before
  - Handles dev/prod naming (dev-bundle.js vs bundle.js)
  - Includes source maps in development mode

### 2. Package Dependencies

**Removed** (Browserify-specific):
- `browserify`, `watchify`, `browserify-incremental`
- `babelify`, `bulkify`, `brfs`
- `babel-preset-react-app`, `babel-plugin-transform-runtime@6`, `babel-polyfill`

**Added** (Webpack & modern Babel):
- `webpack@5`, `webpack-cli@5`
- `babel-loader@9`
- `@babel/core@7`, `@babel/preset-env@7`, `@babel/preset-react@7`
- `@babel/plugin-transform-runtime@7`
- `path-browserify`, `url` (Node.js polyfills)

### 3. Code Changes

#### Replaced `bulk-require` with `require.context`

Webpack has a built-in `require.context()` API that replaces the Browserify `bulk-require` transform.

**Files modified:**
- `app/javascript/models/index.js`
- `app/javascript/react/index.js`
- `app/javascript/react/views/index.js`
- `app/javascript/react/ui-components/index.js`

**Pattern:**
```javascript
// OLD (Browserify with bulkify)
const requireBulk = require('bulk-require')
const modules = requireBulk(__dirname, ['*.js'])

// NEW (Webpack with require.context)
const context = require.context('./', false, /\.js$/)
const modules = {}
context.keys().forEach((key) => {
  const moduleName = key.replace(/^\.\//, '').replace(/\.js$/, '')
  modules[moduleName] = context(key)
})
```

#### Replaced `brfs` with webpack CSV loader

The `brfs` transform was used to inline file reads at build time. Webpack handles this with asset modules.

**File modified:**
- `app/javascript/lib/i18n-translate.js`

**Pattern:**
```javascript
// OLD (Browserify with brfs)
var path = require('path')
var translationsCSVText = require('fs').readFileSync(
  path.join(__dirname, '../../../config/locale/translations.csv'),
  'utf8'
)

// NEW (Webpack with asset/source)
import translationsCSVText from '../../../config/locale/translations.csv'
```

### 4. NPM Scripts

Updated all build/watch scripts to use webpack instead of browserify/watchify:

```json
{
  "build": "mkdir -p public/assets/bundles && NODE_ENV=production webpack",
  "watch": "mkdir -p public/assets/bundles && npm run -s watch:app",
  "build:app": "NODE_ENV=production webpack",
  "watch:app": "NODE_ENV=development webpack --watch"
}
```

## Rails Integration

No changes required! The Rails asset pipeline configuration in `config/initializers/assets.rb` remains unchanged:

- Bundles are still output to `public/assets/bundles/`
- File naming convention is preserved (dev-bundle.js vs bundle.js)
- Rails automatically picks up the bundles via the existing configuration

## Usage

### Development

```bash
# Watch and rebuild on changes (main app only)
npm run watch

# Watch all bundles
npm run watch-all
```

### Production Build

```bash
# Build all bundles for production
npm run build

# Build individual bundles
npm run build:app
npm run build:app-embedded-view
npm run build:server
npm run build:integration
```

## Differences from Browserify

### Positive Changes

1. **Faster builds**: Webpack 5 has better caching and incremental builds
2. **Better tree shaking**: Smaller bundle sizes in production
3. **Modern tooling**: Active development and better ecosystem
4. **Better error messages**: Easier to debug build issues
5. **Built-in features**: No need for external transforms

### Known Warnings

The build produces warnings about missing default exports. These are non-critical and occur because:

- Some modules use CommonJS (`module.exports`) instead of ES6 exports
- Webpack can handle this automatically but warns about it
- The bundles work correctly despite the warnings

To fix these warnings (optional):
1. Convert CommonJS modules to ES6 exports
2. Or use `import * as Module` instead of `import Module`

## Vite Alternative (Not Chosen)

Vite was considered but not chosen because:

1. **Dev server approach**: Vite is designed around a dev server, not pre-bundling
2. **Rails integration**: Would require significant changes to Rails asset handling
3. **Output structure**: Vite generates manifest-based outputs with hashed names
4. **SSR complexity**: Server-side rendering setup would be more complex

Vite would work but requires:
- Changing Rails views to use Vite's manifest.json for asset paths
- Setting up Vite's dev server proxy or separate development workflow
- Restructuring the asset pipeline significantly

Webpack maintains drop-in compatibility with the existing Rails setup.

## Troubleshooting

### Build fails with "webpack: command not found"

Ensure webpack is installed:
```bash
npm install
```

If the issue persists:
```bash
rm -rf node_modules package-lock.json
npm install
```

### "Module not found" errors

Check that all import paths are correct. Webpack's resolution is slightly different from Browserify.

### Large bundle sizes

Webpack 5 includes automatic code splitting. To enable:
1. Update webpack.config.js optimization settings
2. Adjust Rails asset loading to handle code-split chunks

## Future Improvements

1. **Code splitting**: Split large bundles into smaller chunks
2. **CSS handling**: Migrate from Sprockets to webpack for CSS
3. **Hot Module Replacement**: Enable HMR in development
4. **Modern JS**: Update to ES6+ throughout the codebase
5. **Fix export warnings**: Standardize on ES6 exports
