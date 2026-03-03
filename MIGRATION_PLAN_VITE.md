# Migration Plan: Browserify + react-rails to Vite Ruby + Custom ExecJS SSR

## Table of Contents

1. [Overview](#1-overview)
2. [Current Architecture](#2-current-architecture)
3. [Target Architecture](#3-target-architecture)
4. [Prerequisites](#4-prerequisites)
5. [Step 1: Install Vite Ruby Dependencies](#step-1-install-vite-ruby-dependencies)
6. [Step 2: Create Vite Entrypoints](#step-2-create-vite-entrypoints)
7. [Step 3: Replace bulk-require with import.meta.glob](#step-3-replace-bulk-require-with-importmetaglob)
8. [Step 4: Replace brfs Inline File Reads](#step-4-replace-brfs-inline-file-reads)
9. [Step 5: Build Custom ExecJS SSR Renderer](#step-5-build-custom-execjs-ssr-renderer)
10. [Step 6: Migrate Sass from Sprockets to Vite](#step-6-migrate-sass-from-sprockets-to-vite)
11. [Step 7: Update Rails Layouts to Use Vite Tag Helpers](#step-7-update-rails-layouts-to-use-vite-tag-helpers)
12. [Step 8: Fix Remaining Browserify-Specific Patterns](#step-8-fix-remaining-browserify-specific-patterns)
13. [Step 9: Update Build Scripts](#step-9-update-build-scripts)
14. [Step 10: Update Sprockets Configuration](#step-10-update-sprockets-configuration)
15. [Step 11: Clean Up Dependencies](#step-11-clean-up-dependencies)
16. [Step 12: Handle Integration Testbed Bundle](#step-12-handle-integration-testbed-bundle)
17. [Step 13: Update ESLint Configuration](#step-13-update-eslint-configuration)
18. [Step 14: Verification Checklist](#step-14-verification-checklist)
19. [Complete File Change Summary](#complete-file-change-summary)
20. [Risk Mitigation and Rollback Plan](#risk-mitigation-and-rollback-plan)
21. [Future Roadmap](#future-roadmap)

---

## 1. Overview

### Goal

Migrate the Madek webapp build pipeline from Browserify 14 + Sprockets (CSS) + react-rails (SSR) to Vite Ruby (JS + CSS) + custom ExecJS SSR. This replaces the entire build toolchain while keeping React 16.14, all component code, and SSR behavior unchanged.

### Why Vite Ruby

- First-class Rails integration via the `vite_rails` gem (tag helpers, auto-build, config)
- Native Sass support (replaces Ruby Sass + sass-rails)
- HMR (Hot Module Replacement) in development
- Faster builds than Browserify/Webpack
- Positions the codebase for a future React 18 upgrade
- `import.meta.glob` replaces `bulk-require` (Browserify-specific)
- `?raw` imports replace `brfs` (Browserify-specific)

### Why Custom SSR (replacing react-rails)

- `react-rails` v1.10.0 is from 2016 and effectively abandoned
- `react-rails` does NOT support Vite (open issue #1134 since 2021, unresolved)
- `react-rails` does NOT support React 18
- The custom SSR replacement is ~80 lines of Ruby code that does exactly what `react-rails` does
- The custom SSR is designed with a swappable backend interface: ExecJS now, Node.js HTTP service later

### Principles

1. **Change the build pipeline, NOT the application.** No React version changes, no component rewrites, no behavior changes.
2. **Each step is independently testable.** Steps 1-4 (Vite client build) can be verified before touching SSR. Step 5 (custom SSR) can be tested independently. Steps 6-7 (Sass + layouts) are the final switchover.
3. **Maintain exact HTML output compatibility.** The `<div data-react-class="..." data-react-props="...">` structure MUST be identical to what react-rails produces, because client-side hydration depends on it.

---

## 2. Current Architecture

### Build Tools

| Tool       | Version | Purpose                                                  |
| ---------- | ------- | -------------------------------------------------------- |
| Browserify | 14.x    | JS bundling (4 separate bundles)                         |
| Watchify   | 4.x     | Dev file watching                                        |
| Babelify   | 9.x     | Babel transform for Browserify                           |
| Bulkify    | 1.4.x   | `bulk-require` transform (auto-discover modules by glob) |
| Brfs       | 1.4.x   | `fs.readFileSync` inlining at build time                 |
| Sprockets  | 3.7.2   | CSS compilation, font/image fingerprinting               |
| Ruby Sass  | 3.4.25  | Sass compilation (deprecated since 2019)                 |
| Uglifier   | 3.0.4   | JS minification                                          |

### SSR

| Tool        | Version | Purpose                                     |
| ----------- | ------- | ------------------------------------------- |
| react-rails | 1.10.0  | `react_component()` helper + SSR via ExecJS |
| ExecJS      | 2.7.0   | JS runtime for server-side rendering        |

### JS Bundles (Browserify output)

| Bundle            | Entry Point                             | Output (prod)                           | Output (dev)                      |
| ----------------- | --------------------------------------- | --------------------------------------- | --------------------------------- |
| Main App          | `app/javascript/application.js`         | `bundle.js` (6.7MB)                     | `dev-bundle.js` (18MB)            |
| Embedded View     | `app/javascript/embedded-view.js`       | `bundle-embedded-view.js` (2.8MB)       | `dev-bundle-embedded-view.js`     |
| SSR               | `app/javascript/react-server-side.js`   | `bundle-react-server-side.js` (6.1MB)   | `dev-bundle-react-server-side.js` |
| Integration Tests | `app/javascript/integration-testbed.js` | `bundle-integration-testbed.js` (1.3MB) | N/A                               |

### Key Framework Versions

| Framework | Version |
| --------- | ------- |
| Rails     | 7.2.2.2 |
| Ruby      | 3.2.4   |
| Node.js   | 20.19.0 |
| React     | 16.14.0 |
| React DOM | 16.14.0 |

### Current SSR Flow

1. HAML view calls `react('Views.SomeThing', {get: @presenter})` (in `app/helpers/ui_helper.rb:44-56`)
2. `UiHelper#react` dumps the Presenter, injects auth token, calls `react_component("UI.Views.SomeThing", props, prerender: true)` from react-rails
3. react-rails loads `bundle-react-server-side.js` in ExecJS
4. Before render, `FrontendAppConfig.to_js` is injected to set `APP_CONFIG` in the JS context
5. `react-server-side.js` has attached `UI` (all components) to `global`, so react-rails calls `ReactDOMServer.renderToString()` on the component
6. Output: `<div data-react-class="UI.Views.SomeThing" data-react-props="{...}">...server-rendered HTML...</div>`
7. Client-side: `application.js` runs on DOM ready, `ujs/react.js` finds all `[data-react-class]` nodes, resolves the component from `UI`, calls `ReactDOM.render()` to hydrate

### Current Source Files Using Browserify-Specific Features

**`bulk-require` (4 files):**

- `app/javascript/react/index.js` (lines 4, 13, 19)
- `app/javascript/react/ui-components/index.js` (lines 6, 9)
- `app/javascript/react/views/index.js` (lines 1, 2)
- `app/javascript/models/index.js` (lines 7, 9)

**`brfs` / `require('fs').readFileSync` (1 file):**

- `app/javascript/lib/i18n-translate.js` (lines 9-13)

**`require('global')` (2 files):**

- `app/javascript/application.js` (line 30)
- `app/javascript/embedded-view.js` (line 16)
- `app/javascript/developer-tools.js` (line 1)

**Mixed ESM `import` + CommonJS `module.exports` (3 files):**

- `app/javascript/models/index.js`
- `app/javascript/lib/i18n-translate.js`
- `app/javascript/ujs/hashviz.js`

**Sprockets Sass helpers in stylesheets (48 occurrences):**

- `image-url()` in 10 `.sass` files (32 uses)
- `image-url()` in `embedded-view.scss` (2 uses)
- `asset-path()` in `_fonts.scss` (14 uses)

---

## 3. Target Architecture

### Build Tools

| Tool                        | Purpose                                                  |
| --------------------------- | -------------------------------------------------------- |
| Vite 6.x + vite-plugin-ruby | JS bundling, Sass compilation, HMR, asset fingerprinting |
| @vitejs/plugin-react        | React JSX transform, Fast Refresh                        |
| sass-embedded               | Modern Dart Sass (replaces Ruby Sass)                    |
| Sprockets (kept)            | Font/image fingerprinting only (can be removed later)    |

### SSR

| Tool                         | Purpose                                                  |
| ---------------------------- | -------------------------------------------------------- |
| Custom `SsrRenderer` module  | Swappable SSR backend interface                          |
| `SsrRenderer::ExecJsBackend` | ExecJS-based rendering (drop-in react-rails replacement) |
| ExecJS (kept)                | JS runtime for server-side rendering                     |
| connection_pool gem          | Thread-safe ExecJS context pooling                       |

### JS Bundles (Vite output)

| Bundle            | Entry Point                                         | Served By                                        |
| ----------------- | --------------------------------------------------- | ------------------------------------------------ |
| Main App          | `app/javascript/entrypoints/application.js`         | Vite (dev server / production build)             |
| Embedded View     | `app/javascript/entrypoints/embedded-view.js`       | Vite (dev server / production build)             |
| SSR               | `app/javascript/react-server-side-vite.js`          | Separate Vite SSR build (not served to browsers) |
| Integration Tests | `app/javascript/entrypoints/integration-testbed.js` | Vite (production build only)                     |

---

## 4. Prerequisites

- Node.js 20.19.0 (already in `.tool-versions`)
- Ruby 3.2.4 (already in `.tool-versions`)
- Working development environment with Rails server running
- All existing tests passing before starting migration

---

## Step 1: Install Vite Ruby Dependencies

### 1.1 Modify Gemfile

**File: `Gemfile`**

Current content (relevant lines):

```ruby
gem 'react-rails', '= 1.10.0'
gem 'sass'
gem 'sass-rails'
gem 'sprockets-rails', '>= 3.5'
gem 'execjs'
gem 'uglifier'
```

Changes:

- **Remove:** `gem 'react-rails', '= 1.10.0'`
- **Remove:** `gem 'sass'`
- **Remove:** `gem 'sass-rails'`
- **Remove:** `gem 'uglifier'`
- **Add:** `gem 'vite_rails'`
- **Add:** `gem 'connection_pool'`
- **Keep:** `gem 'sprockets-rails', '>= 3.5'` (still needed for fonts/images)
- **Keep:** `gem 'execjs'` (still needed for SSR)

New relevant section:

```ruby
# FRONTEND
gem 'haml-rails'
gem 'kramdown'
gem 'vite_rails'
gem 'connection_pool'
gem 'sprockets-rails', '>= 3.5'
gem 'execjs'
```

Then run:

```bash
bundle install
```

### 1.2 Run the Vite Ruby installer

```bash
bundle exec vite install
```

This auto-generates:

- `config/vite.json`
- `vite.config.ts`
- `bin/vite`
- Adds `vite` and `vite-plugin-ruby` to `package.json`

### 1.3 Configure `config/vite.json`

**Replace the auto-generated file entirely with:**

```json
{
  "all": {
    "sourceCodeDir": "app/javascript",
    "watchAdditionalPaths": ["config/locale/translations.csv"]
  },
  "development": {
    "autoBuild": true,
    "publicOutputDir": "vite-dev",
    "port": 3036
  },
  "test": {
    "autoBuild": true,
    "publicOutputDir": "vite-test",
    "port": 3037
  }
}
```

**Why:**

- `sourceCodeDir: "app/javascript"` matches existing directory structure
- `watchAdditionalPaths` ensures Vite rebuilds when translations CSV changes (replacing Sprockets `depend_on` directives)
- Entrypoints will live in `app/javascript/entrypoints/` (Vite Ruby convention)

### 1.4 Install npm dependencies

```bash
npm install --save-dev vite vite-plugin-ruby @vitejs/plugin-react sass-embedded
```

### 1.5 Configure `vite.config.ts`

**Replace the auto-generated file entirely with:**

```ts
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [RubyPlugin(), react()],
  resolve: {
    alias: {
      '~': path.resolve(__dirname, 'app/javascript')
    }
  },
  server: {
    fs: {
      allow: [
        // Allow importing translations CSV from config/
        path.resolve(__dirname, 'config/locale'),
        // Allow importing stylesheets from app/assets
        path.resolve(__dirname, 'app/assets'),
        // Allow node_modules
        path.resolve(__dirname, 'node_modules'),
        // Allow the default source code dir
        path.resolve(__dirname, 'app/javascript')
      ]
    }
  },
  // Pre-bundle CJS dependencies so Vite's dev server can handle them
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'react-dom/server',
      'jquery',
      'active-lodash',
      'ampersand-app',
      'ampersand-model',
      'ampersand-rest-collection',
      'prop-types',
      'classnames',
      'react-bootstrap',
      'react-day-picker',
      'react-file-drop',
      'react-waypoint',
      'video.js',
      'moment',
      'lodash',
      'xhr',
      'history',
      'linkify-string',
      'linkifyjs',
      'hashblot',
      'babyparse',
      'async',
      'uuid-validate',
      'any_sha1',
      'local-links'
    ]
  },
  css: {
    preprocessorOptions: {
      sass: {
        // Sass load paths for @import resolution
        loadPaths: [
          path.resolve(__dirname, 'app/assets/stylesheets'),
          path.resolve(__dirname, 'node_modules')
        ]
      },
      scss: {
        loadPaths: [
          path.resolve(__dirname, 'app/assets/stylesheets'),
          path.resolve(__dirname, 'node_modules')
        ]
      }
    }
  },
  build: {
    sourcemap: true
  }
})
```

---

## Step 2: Create Vite Entrypoints

Vite Ruby expects entrypoints in `app/javascript/entrypoints/`. These are thin wrappers that import the existing code and stylesheets.

### 2.1 Create directory

```bash
mkdir -p app/javascript/entrypoints
```

### 2.2 Create `app/javascript/entrypoints/application.js`

```js
// Main application entrypoint for Vite
// Import styles (moves Sass from Sprockets to Vite pipeline)
import '../../assets/stylesheets/application.sass'

// Import the existing application bootstrap
import '../application.js'
```

### 2.3 Create `app/javascript/entrypoints/embedded-view.js`

```js
// Embedded view entrypoint for Vite
import '../../assets/stylesheets/embedded-view.scss'
import '../embedded-view.js'
```

### 2.4 Create `app/javascript/entrypoints/application-contrasted.sass`

This is a CSS-only entrypoint for the high-contrast theme:

```sass
// High-contrast theme entrypoint
@import '../../assets/stylesheets/application-contrasted'
```

### 2.5 Create `app/javascript/entrypoints/styleguide.sass`

```sass
// Styleguide CSS entrypoint
@import '../../assets/stylesheets/styleguide'
```

### 2.6 Important: No SSR entrypoint here

The SSR bundle is built separately via a dedicated Vite config (Step 5). It is never served to browsers and should NOT go through Vite Ruby's tag helpers.

---

## Step 3: Replace bulk-require with import.meta.glob

`bulk-require` is a Browserify-specific transform that auto-discovers and requires all files matching glob patterns in a directory, returning a nested object keyed by filename. This is used in 4 files to build the component registry.

Vite's equivalent is `import.meta.glob()`, which returns flat paths. We need a utility to convert flat paths to nested objects.

### 3.1 Create utility: `app/javascript/lib/glob-to-nested.js`

```js
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
```

### 3.2 Rewrite `app/javascript/react/views/index.js`

**Current file (Browserify):**

```js
const requireBulk = require('bulk-require')
module.exports = requireBulk(__dirname, ['*.jsx', '*/*.jsx'])
```

**New file (Vite):**

```js
import { globToNested } from '../lib/glob-to-nested.js'

// import.meta.glob is resolved at build time by Vite (like bulk-require was by Browserify)
// { eager: true } means synchronous loading (required for SSR compatibility)
const modules = import.meta.glob(['./*.jsx', './**/*.jsx'], { eager: true })

export default globToNested(modules)
```

**Why this works:**

- `./*.jsx` matches top-level files: `Base.jsx`, `Dashboard.jsx`, `CollectionShow.jsx`, etc.
- `./**/*.jsx` matches nested files: `My/Uploader.jsx`, `Collection/Index.jsx`, `MediaEntry/MediaEntryEmbedded.jsx`, etc.
- The `index.js` file itself is `.js` not `.jsx`, so it's not matched
- `{ eager: true }` loads all modules synchronously (critical for SSR where everything must be available immediately)
- `globToNested` converts flat paths to the same nested structure `bulk-require` produced

**Expected output structure (must match existing):**

```js
{
  Base: [Component],
  BaseTmpReact: [Component],
  Dashboard: [Component],
  CollectionShow: [Component],
  // ...
  My: {
    Uploader: [Component],
    Settings: [Component],
    Tokens: [Component],
    // ...
  },
  MediaEntry: {
    Index: [Component],
    MediaEntryBrowse: [Component],
    MediaEntryEmbedded: [Component],
    // ...
  },
  Collection: {
    Index: [Component],
    ResourceSelection: [Component],
    // ...
  },
  Vocabularies: {
    VocabulariesIndex: [Component],
    VocabularyShow: [Component],
    // ...
  },
  // ...other subdirectories
}
```

### 3.3 Rewrite `app/javascript/react/ui-components/index.js`

**Current file (Browserify):**

```js
const requireBulk = require('bulk-require')
const resourceName = require('../lib/decorate-resource-names.js')

const UILibrary = requireBulk(__dirname, ['*.jsx'])
UILibrary.propTypes = require('./propTypes.js')

UILibrary.labelize = resourceList =>
  resourceList.map((resource, i) => ({
    children: resourceName(resource),
    href: resource.url,
    key: `${resource.uuid}-${i}`
  }))

UILibrary.resourceName = resourceName

module.exports = UILibrary
```

**New file (Vite):**

```js
import { globToFlat } from '../lib/glob-to-nested.js'
import resourceName from '../lib/decorate-resource-names.js'
import propTypes from './propTypes.js'

// Only top-level *.jsx files (NOT subdirectories like ResourcesBox/)
const modules = import.meta.glob('./*.jsx', { eager: true })
const UILibrary = globToFlat(modules)

UILibrary.propTypes = propTypes

// build tag from name and url and provide unique key
UILibrary.labelize = resourceList =>
  resourceList.map((resource, i) => ({
    children: resourceName(resource),
    href: resource.url,
    key: `${resource.uuid}-${i}`
  }))

UILibrary.resourceName = resourceName

export default UILibrary
```

**Note:** `globToFlat` is used (not `globToNested`) because `ui-components/` has only top-level `.jsx` files. The `ResourcesBox/` subdirectory contains sub-components that are imported directly by their parent components, not exposed in the UI library index.

### 3.4 Rewrite `app/javascript/react/index.js`

**Current file (Browserify):**

```js
// collect top-level components needed for ujs and/or server-side render:

// Does not work with ESM
const requireBulk = require('bulk-require') // require file/directory trees

module.exports = {
  // "UI library" (aka styleguide)
  // NOTE: 'requireBulk' is in the index file so that other components can use it
  UI: require('./ui-components/index.js'),

  // Decorators: components that directly receive (sub-)presenters
  // NOTE: only needed for remaining HAML views…
  Deco: requireBulk(__dirname, ['./decorators/*.{c,}js{x,}', './decorators/**/*.{c,}js{x,}'])
    .decorators,

  // Views: Everything else that is rendered top-level (`react` helper)
  // NOTE: also because of HAML views there are sub-folders for "partials and actions".
  //       Will be structured more closely to the actual routes where they are used.
  Views: requireBulk(__dirname, ['./views/*.{c,}js{x,}', './views/**/*.{c,}js{x,}']).views,

  // App/Layout things that are only temporarly used from HAML:
  App: {
    UserMenu: require('../react/views/_layouts/UserMenu.jsx'),
    LoginMenu: require('../react/views/_layouts/LoginMenu.jsx').default,
    TestLoginForm: require('../react/views/_layouts/TestLoginForm.jsx').default
  }
}
```

**New file (Vite):**

```js
// collect top-level components needed for ujs and/or server-side render:

import { globToNested } from '../lib/glob-to-nested.js'
import UI from './ui-components/index.js'
import Views from './views/index.js'
import UserMenu from './views/_layouts/UserMenu.jsx'
import { default as LoginMenu } from './views/_layouts/LoginMenu.jsx'
import { default as TestLoginForm } from './views/_layouts/TestLoginForm.jsx'

// Decorators: auto-discover all files in decorators/ tree
// Strip './decorators/' prefix so result is: { BatchAddToSet: ..., resourcesbox: { ... } }
const decoratorModules = import.meta.glob(
  ['./decorators/*.{js,jsx}', './decorators/**/*.{js,jsx}'],
  { eager: true }
)
const Deco = globToNested(decoratorModules, './decorators/')

export default {
  UI,
  Deco,
  Views,
  // App/Layout things that are only temporarily used from HAML:
  App: {
    UserMenu,
    LoginMenu,
    TestLoginForm
  }
}
```

**Critical detail about Deco:** The original code accessed `.decorators` on the `bulk-require` result because `bulk-require` wraps everything under the directory name. With `import.meta.glob`, paths are relative to the file (e.g., `./decorators/BatchAddToSet.jsx`). By passing `'./decorators/'` as the `stripPrefix` argument to `globToNested`, we get the correct flat/nested structure directly.

**Expected Deco structure:**

```js
{
  BatchAddToSet: [Component],
  BatchRemoveFromSet: [Component],
  MediaResourcesBox: [Component],
  ResourceThumbnail: [Component],
  // ... 40+ more top-level decorators
  resourcesbox: {
    ActionsDropdown: [Component],
    Clipboard: [Component],
    // ...
  },
  thumbnail: {
    DeleteModal: [Component],
    FavoriteButton: [Component],
    StatusIcon: [Component]
  },
  metadataedit: {
    MetadataEditRenderer: [Component]
  },
  mediaResourcesBoxState: {
    dataFetchers: [Module],
    state: [Module]
  }
}
```

### 3.5 Rewrite `app/javascript/models/index.js`

**Current file (Browserify):**

```js
import f from 'active-lodash'
import requireBulk from 'bulk-require'

const index = requireBulk(__dirname, ['*.js'])

const Models = f.object(
  f.filter(
    f.map(index, function (val, key) {
      if (!(key === 'index')) {
        return [f.capitalize(f.camelCase(key)), val]
      }
    })
  )
)

module.exports = Models
```

**New file (Vite):**

```js
import f from 'active-lodash'

const modules = import.meta.glob('./*.js', { eager: true })

const Models = {}
for (const [path, mod] of Object.entries(modules)) {
  const filename = path.replace('./', '').replace(/\.js$/, '')
  if (filename === 'index') continue
  // Convert kebab-case filename to PascalCase key (matching original behavior)
  const key = f.capitalize(f.camelCase(filename))
  Models[key] = mod.default !== undefined ? mod.default : mod
}

export default Models
```

**Why:** The original code used `f.capitalize(f.camelCase(key))` to convert filenames like `media-entry` to `MediaEntry`. The new code does exactly the same transformation on the filename extracted from the glob path.

---

## Step 4: Replace brfs Inline File Reads

`brfs` is a Browserify transform that replaces `require('fs').readFileSync()` calls with the actual file contents at build time. It is used in exactly one file.

### 4.1 Rewrite `app/javascript/lib/i18n-translate.js`

**Current file (Browserify + brfs):**

```js
// provides string translation function.
// usage
// import/require as t; t('hello') // => 'Hallo'

import f from 'active-lodash'
import parseTranslationsFromCSV from './parse-translations-from-csv.js'

// NOTE: this works with browserify and the 'brfs' transform (embeds as string)
var path = require('path')
var translationsCSVText = require('fs').readFileSync(
  path.join(__dirname, '../../../config/locale/translations.csv'),
  'utf8'
)

// parses CSV and returns list like: [{lang: 'en', mapping: {key: 'value'}}, …]
var translationsList = parseTranslationsFromCSV(translationsCSVText)
var translations = f.zipObject(
  f.map(translationsList, function (item) {
    return [item.lang, item.mapping]
  })
)

module.exports = function I18nTranslate(marker) {
  // get language from (global) app config
  var LANG = APP_CONFIG.userLanguage

  if (!f.includes(f.keys(translations), LANG)) {
    throw new Error(`Unknown language '${LANG}'!`)
  }

  const s = f.get(translations, [LANG, marker])

  return f.isString(s) ? s : '\u27E8' + marker + '\u27E9'
}
```

**New file (Vite):**

```js
// provides string translation function.
// usage: import t from './i18n-translate'; t('hello') // => 'Hallo'

import f from 'active-lodash'
import parseTranslationsFromCSV from './parse-translations-from-csv.js'

// Vite's ?raw suffix imports file content as a string (replaces brfs transform)
import translationsCSVText from '../../../config/locale/translations.csv?raw'

// parses CSV and returns list like: [{lang: 'en', mapping: {key: 'value'}}, …]
var translationsList = parseTranslationsFromCSV(translationsCSVText)
var translations = f.zipObject(
  f.map(translationsList, function (item) {
    return [item.lang, item.mapping]
  })
)

export default function I18nTranslate(marker) {
  // get language from (global) app config
  var LANG = APP_CONFIG.userLanguage

  if (!f.includes(f.keys(translations), LANG)) {
    throw new Error(`Unknown language '${LANG}'!`)
  }

  const s = f.get(translations, [LANG, marker])

  return f.isString(s) ? s : '\u27E8' + marker + '\u27E9'
}
```

**Changes:**

1. Replaced `require('fs').readFileSync(path.join(__dirname, '...'), 'utf8')` with `import ... from '...?raw'`
2. Removed `require('path')` (no longer needed)
3. Changed `module.exports = function` to `export default function`

**Note:** The `?raw` suffix is a Vite built-in feature. The CSV file path `../../../config/locale/translations.csv` is relative to the file's location (`app/javascript/lib/`). This resolves to `config/locale/translations.csv` which is outside `sourceCodeDir`. The `server.fs.allow` config in `vite.config.ts` (Step 1.5) permits this.

---

## Step 5: Build Custom ExecJS SSR Renderer

This replaces the `react-rails` gem with custom code. The custom SSR is designed with a swappable backend interface so you can later replace ExecJS with a Node.js HTTP service without changing any view code.

### 5.1 Create `app/lib/ssr_renderer.rb`

```ruby
# Custom SSR renderer using ExecJS, replacing react-rails gem.
# Designed so the backend can be swapped to Node.js HTTP service later.
#
# Usage in views (identical to before):
#   SsrRenderer.render('Views.Dashboard', { get: presenter_data })
#
# The backend is swappable:
#   - Phase 1 (now): ExecJsBackend (same as react-rails internally)
#   - Phase 2 (future): NodeBackend (HTTP call to Express/Fastify service)

module SsrRenderer
  class Error < StandardError; end

  def self.render(component_name, props)
    backend.render(component_name, props)
  end

  # Call this to force re-creation of the backend (e.g., when SSR bundle changes)
  def self.reset!
    @backend = nil
  end

  private

  def self.backend
    @backend ||= ExecJsBackend.new
  end
end
```

### 5.2 Create `app/lib/ssr_renderer/exec_js_backend.rb`

```ruby
require 'connection_pool'

module SsrRenderer
  class ExecJsBackend
    def initialize
      @pool = ConnectionPool.new(
        size: pool_size,
        timeout: render_timeout
      ) { create_context }
    end

    # Render a React component to HTML string.
    # component_name: e.g., "Views.Dashboard" (without "UI." prefix)
    # props: Hash of component props (already serialized, no Presenter objects)
    def render(component_name, props)
      @pool.with do |context|
        context.call('renderComponent', component_name, props)
      end
    rescue => e
      Rails.logger.error("[SSR] Render failed for #{component_name}: #{e.message}")
      Rails.logger.error(e.backtrace.first(5).join("\n")) if e.backtrace
      "" # Fall back to client-only rendering (empty string = no server HTML)
    end

    private

    def create_context
      js = []
      js << FrontendAppConfig.to_js
      js << bundle_contents
      js << render_function_js
      ExecJS.compile(js.join("\n;\n"))
    end

    def bundle_contents
      File.read(bundle_path)
    end

    def bundle_path
      if Rails.env.development?
        Rails.root.join('public/assets/bundles/dev-bundle-react-server-side.js')
      else
        Rails.root.join('public/assets/bundles/bundle-react-server-side.js')
      end
    end

    # JavaScript function that the ExecJS context exposes.
    # It resolves a dotted component name (e.g., "Views.My.Uploader")
    # from the global UI object and renders it to an HTML string.
    def render_function_js
      <<~JS
        function renderComponent(name, props) {
          var component = name.split('.').reduce(function(obj, key) {
            return obj && obj[key];
          }, UI);
          if (!component) {
            throw new Error('Component not found: UI.' + name);
          }
          var element = React.createElement(component, props);
          return ReactDOMServer.renderToString(element);
        }
      JS
    end

    def pool_size
      Rails.configuration.x.ssr_pool_size ||
        (Rails.env.production? ? 12 : 1)
    end

    def render_timeout
      Rails.configuration.x.ssr_timeout || 10
    end
  end
end
```

**How this matches react-rails internally:**

- react-rails `SprocketsRenderer` loads a JS bundle into ExecJS, attaches `React`, `ReactDOMServer`, and `UI` to `global`, then calls `ReactDOMServer.renderToString(React.createElement(component, props))`
- Our `ExecJsBackend` does exactly the same thing
- The `ConnectionPool` replaces react-rails' `React::ServerRendering::SprocketsRenderer` pool

### 5.3 Rewrite `react()` helper in `app/helpers/ui_helper.rb`

**Current `react()` method (lines 44-56):**

```ruby
def react(name, props = {}, opts = {})
  defaults = { prerender: !params.permit(:___norender).present? }
  opts = defaults.merge(opts)
  maybe_presenter = props[:get]
  if maybe_presenter.is_a?(Presenter)
    # NOTE: all of the queries happen here:
    props = props.merge(get: maybe_presenter.dump)
  end
  # inject route + auth token for all "top-level" components (aka Views)
  props = props.merge(
    authToken: form_authenticity_token, for_url: request.original_fullpath)
  react_component("UI.#{name}", props, opts)
end
```

**New `react()` method:**

```ruby
def react(name, props = {}, opts = {})
  prerender = opts.fetch(:prerender, !params.permit(:___norender).present?)

  maybe_presenter = props[:get]
  if prerender && maybe_presenter.is_a?(Presenter)
    # NOTE: all of the queries happen here:
    props = props.merge(get: maybe_presenter.dump)
  end

  # inject route + auth token for all "top-level" components (aka Views)
  props = props.merge(
    authToken: form_authenticity_token, for_url: request.original_fullpath)

  json_props = props.as_json

  html = if prerender
    SsrRenderer.render(name, json_props)
  else
    ""
  end

  content_tag(:div, html.html_safe,
    data: {
      react_class: "UI.#{name}",
      react_props: json_props.to_json
    }
  )
end
```

**CRITICAL: HTML output must be identical to react-rails.**

react-rails produces:

```html
<div data-react-class="UI.Views.Dashboard" data-react-props="{...}">...server-rendered HTML...</div>
```

Our new code produces:

```html
<div data-react-class="UI.Views.Dashboard" data-react-props="{...}">...server-rendered HTML...</div>
```

The client-side hydration code (`app/javascript/ujs/react.js`) finds elements by `[data-react-class]` and reads `data-react-props` -- this is unchanged.

### 5.4 Create SSR bundle entry point

**Create `app/javascript/react-server-side-vite.js`:**

```js
// SSR bundle entry point for Vite.
// This bundle runs inside ExecJS, NOT in a browser.
// It attaches React and the full component tree to globalThis
// so the Ruby SsrRenderer can call renderComponent().

import React from 'react'
import ReactDOMServer from 'react-dom/server'
import ReactDOM from 'react-dom'
import UI from './react/index.js'

// Attach to global scope for ExecJS access
globalThis.React = React
globalThis.ReactDOMServer = ReactDOMServer
globalThis.ReactDOM = ReactDOM
globalThis.UI = UI
```

### 5.5 Create SSR Vite build config

**Create `vite.config.ssr.ts`:**

```ts
import { defineConfig } from 'vite'
import path from 'path'

export default defineConfig({
  resolve: {
    alias: {
      '~': path.resolve(__dirname, 'app/javascript')
    }
  },
  build: {
    ssr: true,
    rollupOptions: {
      input: path.resolve(__dirname, 'app/javascript/react-server-side-vite.js'),
      output: {
        // ExecJS needs a self-contained script, NOT ESM modules.
        // IIFE wraps everything in an immediately-invoked function.
        format: 'iife',
        name: 'SSRBundle',
        entryFileNames: 'bundle-react-server-side.js',
        // Inline everything (ExecJS can't import/require external modules)
        inlineDynamicImports: true
      }
    },
    // Don't externalize anything - ExecJS needs everything bundled
    commonjsOptions: {
      include: [/node_modules/],
      transformMixedEsModules: true
    },
    outDir: path.resolve(__dirname, 'public/assets/bundles'),
    emptyOutDir: false, // Don't delete other files in the bundles directory
    sourcemap: false // ExecJS doesn't support source maps
  }
})
```

**CRITICAL: The `iife` format is essential.** ExecJS executes JavaScript in an isolated context that cannot `require()` or `import` external modules. The entire bundle must be self-contained. The `iife` format wraps all code in `(function() { ... })()` which executes immediately and attaches everything to `globalThis`.

### 5.6 Create SSR auto-reload initializer for development

**Create `config/initializers/ssr.rb`:**

```ruby
# Auto-reload SSR context when bundle changes in development
if Rails.env.development?
  ssr_bundle_path = Rails.root.join(
    'public/assets/bundles/dev-bundle-react-server-side.js'
  ).to_s

  # Watch the SSR bundle file for changes
  Rails.application.config.watchable_files << ssr_bundle_path

  # Reset the SSR renderer when files change (forces re-read of bundle)
  ActiveSupport::Reloader.to_prepare do
    SsrRenderer.reset!
  end
end
```

### 5.7 Configure SSR pool in production

**In `config/environments/production.rb`, replace lines 60-62:**

Current:

```ruby
# Use multi-threaded React renderer in production (jruby!)
config.react.server_renderer_pool_size = 12
config.react.server_renderer_timeout   = 10 # seconds
```

New:

```ruby
# SSR renderer pool configuration
config.x.ssr_pool_size = 12
config.x.ssr_timeout = 10 # seconds
```

### 5.8 Remove react-rails configuration from `config/application.rb`

**Remove lines 94-114:**

```ruby
# Assets & React

# react-rails config:
# Settings for the pool of renderers:
# config.react.server_renderer_pool_size  ||= 1  # ExecJS doesn't allow more than one on MRI
# config.react.server_renderer_timeout    ||= 20 # seconds
# config.react.server_renderer = React::ServerRendering::SprocketsRenderer

config.react.server_renderer_options = {
  files: ['bundle-react-server-side.js'].flatten,
  replay_console: false
}

config.after_initialize do
  # inject (per-instance) app config into react renderer:
  class React::ServerRendering::SprocketsRenderer
    def before_render(_component_name, _props, _prerender_options)
      FrontendAppConfig.to_js
    end
  end
end
```

**Keep the rest of the file unchanged** (middleware, eager_load_paths, etc.).

### 5.9 Remove react-rails configuration from `config/environments/development.rb`

**Remove lines 85-92:**

```ruby
# use dev bundle for SSR
config.react.server_renderer_options = {
  files: ['dev-bundle-react-server-side.js'].flatten,
  replay_console: false
}

# auto-reload SSR renderer when dev bundle changes
config.watchable_files.concat([root.join('public/assets/bundles/dev-bundle-react-server-side.js').to_s])
```

This is replaced by `config/initializers/ssr.rb` (Step 5.6).

---

## Step 6: Migrate Sass from Sprockets to Vite

### 6.1 Replace Sprockets `image-url()` helper in Sass files

There are **34 occurrences** of `image-url()` across `.sass` and `.scss` files. This is a Sprockets helper that returns a fingerprinted URL. In Vite, CSS `url()` references are automatically processed.

**Strategy:** Define a custom Sass function `image-url()` that outputs a plain CSS `url()` with the correct relative path.

**In `vite.config.ts`, update the `css.preprocessorOptions` section:**

```ts
css: {
  preprocessorOptions: {
    sass: {
      // Inject image-url() function replacement for Sprockets compatibility
      additionalData: `
@function image-url($path)
  @return url("../images/" + $path)
`,
      loadPaths: [
        path.resolve(__dirname, 'app/assets/stylesheets'),
        path.resolve(__dirname, 'node_modules')
      ]
    },
    scss: {
      // Same for SCSS syntax files
      additionalData: `
@function image-url($path) {
  @return url("../images/" + $path);
}
`,
      loadPaths: [
        path.resolve(__dirname, 'app/assets/stylesheets'),
        path.resolve(__dirname, 'node_modules')
      ]
    }
  }
}
```

**Why `../images/`:** The Sass files are in `app/assets/stylesheets/`. The images are in `app/assets/images/`. The relative path from stylesheets to images is `../images/`. Vite will resolve these paths and process the referenced files (hashing, copying to output).

### 6.2 Replace `asset-path()` in `_fonts.scss`

`asset-path()` is a Sprockets helper that returns a bare path (not wrapped in `url()`). It's used for font file references.

**Current file: `app/assets/stylesheets/_fonts.scss`**

```scss
@font-face {
  font-family: 'FontAwesome';
  src:
    url(asset-path('fontawesome-webfont.eot?#iefix')) format('embedded-opentype'),
    url(asset-path('fontawesome-webfont.woff2')) format('woff2'),
    url(asset-path('fontawesome-webfont.woff')) format('woff'),
    url(asset-path('fontawesome-webfont.ttf')) format('truetype'),
    url(asset-path('fontawesome-webfont.svg#fontawesomeregular')) format('svg');
  font-weight: normal;
  font-style: normal;
}
@import '../../../node_modules/font-awesome/scss/variables';
@import '../../../node_modules/font-awesome/scss/mixins';
@import '../../../node_modules/font-awesome/scss/core';
@import '../../../node_modules/font-awesome/scss/icons';
@import '../../../node_modules/font-awesome/scss/screen-reader';

@font-face {
  font-family: 'Open Sans';
  font-weight: 400;
  src:
    url(asset-path('TypoPRO-OpenSans-Regular.eot?#iefix')) format('embedded-opentype'),
    url(asset-path('TypoPRO-OpenSans-Regular.woff')) format('woff'),
    url(asset-path('TypoPRO-OpenSans-Regular.ttf')) format('truetype');
}

@font-face {
  font-family: 'Open Sans';
  font-weight: 600;
  src:
    url(asset-path('TypoPRO-OpenSans-Semibold.eot?#iefix')) format('embedded-opentype'),
    url(asset-path('TypoPRO-OpenSans-Semibold.woff')) format('woff'),
    url(asset-path('TypoPRO-OpenSans-Semibold.ttf')) format('truetype');
}

@font-face {
  font-family: 'Open Sans';
  font-weight: 700;
  src:
    url(asset-path('TypoPRO-OpenSans-Bold.eot?#iefix')) format('embedded-opentype'),
    url(asset-path('TypoPRO-OpenSans-Bold.woff')) format('woff'),
    url(asset-path('TypoPRO-OpenSans-Bold.ttf')) format('truetype');
}
```

**New file:**

```scss
// custom icon font from own assets
@import 'icons';

// Font Awesome icon font - use direct node_modules paths
@font-face {
  font-family: 'FontAwesome';
  src:
    url('../../../node_modules/font-awesome/fonts/fontawesome-webfont.eot?#iefix')
      format('embedded-opentype'),
    url('../../../node_modules/font-awesome/fonts/fontawesome-webfont.woff2') format('woff2'),
    url('../../../node_modules/font-awesome/fonts/fontawesome-webfont.woff') format('woff'),
    url('../../../node_modules/font-awesome/fonts/fontawesome-webfont.ttf') format('truetype'),
    url('../../../node_modules/font-awesome/fonts/fontawesome-webfont.svg#fontawesomeregular')
      format('svg');
  font-weight: normal;
  font-style: normal;
}
@import '../../../node_modules/font-awesome/scss/variables';
@import '../../../node_modules/font-awesome/scss/mixins';
@import '../../../node_modules/font-awesome/scss/core';
@import '../../../node_modules/font-awesome/scss/icons';
@import '../../../node_modules/font-awesome/scss/screen-reader';

// Main font: Open Sans - use direct node_modules paths
@font-face {
  font-family: 'Open Sans';
  font-weight: 400;
  src:
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Regular.eot?#iefix')
      format('embedded-opentype'),
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Regular.woff')
      format('woff'),
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Regular.ttf')
      format('truetype');
}

@font-face {
  font-family: 'Open Sans';
  font-weight: 600;
  src:
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Semibold.eot?#iefix')
      format('embedded-opentype'),
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Semibold.woff')
      format('woff'),
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Semibold.ttf')
      format('truetype');
}

@font-face {
  font-family: 'Open Sans';
  font-weight: 700;
  src:
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Bold.eot?#iefix')
      format('embedded-opentype'),
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Bold.woff')
      format('woff'),
    url('../../../node_modules/@eins78/typopro-open-sans/dist/TypoPRO-OpenSans-Bold.ttf')
      format('truetype');
}
```

**Note:** The relative paths from `app/assets/stylesheets/_fonts.scss` to `node_modules/` go up three directories (`../../../node_modules/`). Vite resolves these paths and copies the font files to the output directory with content hashing.

### 6.3 Handle the `madek-logo-svg()` and `video-js-theme` imports in `embedded-view.scss`

`embedded-view.scss` imports `madek_logo_svg` and `video-js-theme`. These are likely Sass files in `app/assets/stylesheets/`. Verify these files exist and their content. They should work without changes since Vite's Sass `loadPaths` includes `app/assets/stylesheets/`.

The `url(madek-logo-svg(white))` call on lines 82 and 203 of `embedded-view.scss` is a custom Sass function. Verify that `_madek_logo_svg.sass` or `_madek_logo_svg.scss` defines this function. If it's a Sass function that returns a data URI, it will work as-is with Vite.

### 6.4 Verify image assets exist

All images referenced via `image-url()` must exist at `app/assets/images/`. Verify:

```bash
ls app/assets/images/backgrounds/
# Expected: body-background.png, container-midtone.png, container-midtone-darker.png,
#           preloader-*.gif, page-title-overflow.png, thumb-video-backg*.png, etc.

ls app/assets/images/
# Expected: animated-static-noise.gif (used by embedded-view.scss)
```

---

## Step 7: Update Rails Layouts to Use Vite Tag Helpers

### 7.1 Update `app/views/layouts/_base.haml`

**Current file:**

```haml
:ruby
  #NOTE: careful with access to `settings` comes from DB and can fail hard
  extra_content = begin; settings.webapp_html_extra_content; rescue; end || {}
  site_title = begin; localize(settings.site_titles); rescue; end
  site_title ||= 'Madek' # fallback

!!!
-# NOTE: class 'has-js' is set dynamically with — suprise! — JavaScript.
%html{lang: locale, prefix: 'og: http://ogp.me/ns#'}
  %head
    %meta{charset: 'utf-8'}

    -# configured extra tags for head start:
    = find_and_preserve(extra_content[:head_start].html_safe) if extra_content[:head_start].present?

    %title
      - if content_for?(:title_head)
        = "#{site_title} | #{strip_tags(content_for(:title_head))}"
      - else
        = site_title

    -# 1. init ujs as early as possible (sets class so correct styles are used)
    -# 2. add 'dynamic' config (that can't be bundled)
    - if use_js
      :javascript
        document.getElementsByTagName('html')[0].classList.add('has-js')
        #{FrontendAppConfig.to_js}

    = stylesheet_link_tag 'application', media: 'all'
    = content_for(:style_head)

    = csrf_meta_tag

    -# optional extra tags for head:
    = content_for(:head)

    -# configured extra tags for head end:
    = find_and_preserve(extra_content[:head_end].html_safe) if extra_content[:head_end].present?

  - uberadmin_mode = current_user.try(:admin).try(:webapp_session_uberadmin_mode)
  %body{data: {r: controller_name, a: action_name, uberadmin: uberadmin_mode }}

    -# configured extra content for body start:
    = find_and_preserve(extra_content[:body_start].html_safe) if extra_content[:body_start].present?

    -# main body from ruby block or named content block
    - if content_for?(:body)
      = content_for(:body)
    - elsif block_given?
      = yield

    - if use_js
      -# js: app lib/dependencies. can't use async/defer (would require sep. DOM ops)
      - if Rails.env == 'development'
        = javascript_include_tag 'dev-bundle'
      - else
        = javascript_include_tag 'bundle'
      -# - now all the per-template scripts, which
          MUST be self-contained and not depending on load order:
      = content_for(:scripts) if content_for?(:scripts)

    -# configured extra content for body end:
    = find_and_preserve(extra_content[:body_end].html_safe) if extra_content[:body_end].present?
```

**New file:**

```haml
:ruby
  #NOTE: careful with access to `settings` comes from DB and can fail hard
  extra_content = begin; settings.webapp_html_extra_content; rescue; end || {}
  site_title = begin; localize(settings.site_titles); rescue; end
  site_title ||= 'Madek' # fallback

!!!
-# NOTE: class 'has-js' is set dynamically with — suprise! — JavaScript.
%html{lang: locale, prefix: 'og: http://ogp.me/ns#'}
  %head
    %meta{charset: 'utf-8'}

    -# configured extra tags for head start:
    = find_and_preserve(extra_content[:head_start].html_safe) if extra_content[:head_start].present?

    %title
      - if content_for?(:title_head)
        = "#{site_title} | #{strip_tags(content_for(:title_head))}"
      - else
        = site_title

    -# 1. init ujs as early as possible (sets class so correct styles are used)
    -# 2. add 'dynamic' config (that can't be bundled)
    - if use_js
      :javascript
        document.getElementsByTagName('html')[0].classList.add('has-js')
        #{FrontendAppConfig.to_js}

      -# Vite client (enables HMR in development, no-op in production)
      = vite_client_tag
      -# Main app JS + CSS (Vite automatically includes extracted CSS)
      = vite_javascript_tag 'application'
    - else
      -# CSS-only fallback when JS is disabled
      = vite_stylesheet_tag 'application', media: 'all'

    = content_for(:style_head)

    = csrf_meta_tag

    -# optional extra tags for head:
    = content_for(:head)

    -# configured extra tags for head end:
    = find_and_preserve(extra_content[:head_end].html_safe) if extra_content[:head_end].present?

  - uberadmin_mode = current_user.try(:admin).try(:webapp_session_uberadmin_mode)
  %body{data: {r: controller_name, a: action_name, uberadmin: uberadmin_mode }}

    -# configured extra content for body start:
    = find_and_preserve(extra_content[:body_start].html_safe) if extra_content[:body_start].present?

    -# main body from ruby block or named content block
    - if content_for?(:body)
      = content_for(:body)
    - elsif block_given?
      = yield

    - if use_js
      -# per-template scripts (must be self-contained):
      = content_for(:scripts) if content_for?(:scripts)

    -# configured extra content for body end:
    = find_and_preserve(extra_content[:body_end].html_safe) if extra_content[:body_end].present?
```

**Key changes:**

1. Replaced `stylesheet_link_tag 'application'` with `vite_javascript_tag 'application'` (Vite auto-includes extracted CSS)
2. Added `vite_client_tag` before `vite_javascript_tag` (required for HMR in dev)
3. Added `vite_stylesheet_tag` fallback for no-JS case
4. Removed the `javascript_include_tag 'dev-bundle'` / `'bundle'` block at the bottom of `<body>` (Vite's `<script type="module">` in `<head>` is deferred by default)
5. Kept `content_for(:scripts)` for any per-template scripts

**Important:** Vite outputs `<script type="module">` which is deferred by default (equivalent to `defer` attribute). This means the script executes after HTML parsing, just like placing `<script>` at the end of `<body>`. The existing `$(document).ready()` pattern still works correctly.

### 7.2 Update `app/views/layouts/_embedded.html.haml`

**Current file:**

```haml
-# Base template for embedded player, only used inside an iframe (inside webapp and externally)
-# NOTE: when changing this, also see `_fullscreen.html.haml` if the same changes should be applied there as well

:ruby
  # NOTE: careful with access to `settings` comes from DB and can fail hard
  extra_content = begin; settings.webapp_html_extra_content; rescue; end || {}
  site_title = begin; localize(settings.site_titles); rescue; end
  site_title ||= 'Madek' # fallback
  title = begin; @get[:title]; rescue; end
  lang = locale
  body_data = begin; { 'referer-host': @get[:embed_config]['referer_info']['host'] }; rescue; end || {}

!!!
%html{lang: lang}
  %head
    %meta{charset: 'utf-8'}

    -# configured extra tags for head start:
    = find_and_preserve(extra_content[:head_start].html_safe) if extra_content[:head_start].present?

    %title= title ? "#{strip_tags(title)} | #{site_title}" : site_title

    :javascript
      document.getElementsByTagName('html')[0].classList.add('has-js')
      #{FrontendAppConfig.to_js}

    = stylesheet_link_tag 'embedded-view', media: 'all'

    -# configured extra tags for head end:
    = find_and_preserve(extra_content[:head_end].html_safe) if extra_content[:head_end].present?

  %body{data: ({embedded_view: true}).merge(body_data)}

    -# configured extra content for body start:
    = find_and_preserve(extra_content[:body_start].html_safe) if extra_content[:body_start].present?

    = content_for(:body)

    - if Rails.env == 'development'
      = javascript_include_tag 'dev-bundle-embedded-view'
    - else
      = javascript_include_tag 'bundle-embedded-view'

    -# configured extra content for body end:
    = find_and_preserve(extra_content[:body_end].html_safe) if extra_content[:body_end].present?
```

**New file:**

```haml
-# Base template for embedded player, only used inside an iframe (inside webapp and externally)
-# NOTE: when changing this, also see `_fullscreen.html.haml` if the same changes should be applied there as well

:ruby
  # NOTE: careful with access to `settings` comes from DB and can fail hard
  extra_content = begin; settings.webapp_html_extra_content; rescue; end || {}
  site_title = begin; localize(settings.site_titles); rescue; end
  site_title ||= 'Madek' # fallback
  title = begin; @get[:title]; rescue; end
  lang = locale
  body_data = begin; { 'referer-host': @get[:embed_config]['referer_info']['host'] }; rescue; end || {}

!!!
%html{lang: lang}
  %head
    %meta{charset: 'utf-8'}

    -# configured extra tags for head start:
    = find_and_preserve(extra_content[:head_start].html_safe) if extra_content[:head_start].present?

    %title= title ? "#{strip_tags(title)} | #{site_title}" : site_title

    :javascript
      document.getElementsByTagName('html')[0].classList.add('has-js')
      #{FrontendAppConfig.to_js}

    = vite_client_tag
    = vite_javascript_tag 'embedded-view'

    -# configured extra tags for head end:
    = find_and_preserve(extra_content[:head_end].html_safe) if extra_content[:head_end].present?

  %body{data: ({embedded_view: true}).merge(body_data)}

    -# configured extra content for body start:
    = find_and_preserve(extra_content[:body_start].html_safe) if extra_content[:body_start].present?

    = content_for(:body)

    -# configured extra content for body end:
    = find_and_preserve(extra_content[:body_end].html_safe) if extra_content[:body_end].present?
```

**Changes:**

1. Replaced `stylesheet_link_tag 'embedded-view'` with `vite_javascript_tag 'embedded-view'` (CSS imported by JS entrypoint)
2. Added `vite_client_tag`
3. Removed the environment-conditional `javascript_include_tag` block at the bottom

### 7.3 Update `app/views/layouts/_fullscreen.html.haml`

**Apply the same changes as `_embedded.html.haml`:**

Replace:

```haml
    = stylesheet_link_tag 'embedded-view', media: 'all'
```

with:

```haml
    = vite_client_tag
    = vite_javascript_tag 'embedded-view'
```

Remove:

```haml
    - if Rails.env == 'development'
      = javascript_include_tag 'dev-bundle-embedded-view'
    - else
      = javascript_include_tag 'bundle-embedded-view'
```

Keep the viewport meta tags that `_fullscreen` has but `_embedded` doesn't.

---

## Step 8: Fix Remaining Browserify-Specific Patterns

### 8.1 Fix `app/javascript/developer-tools.js`

**Current file:**

```js
const global = require('global')

global.$ = require('jquery')
global.f = require('active-lodash')
global.React = require('react')
global.ReactDOM = require('react-dom')

global.App = {
  UI: require('./react/index.js'),
  Models: require('./models/index.js'),
  t: require('./lib/i18n-translate.js')
}

global.UI = global.App.UI
global.Models = global.App.Models
```

**New file:**

```js
// Developer tools - exposes key modules on window for REPL debugging

import $ from 'jquery'
import f from 'active-lodash'
import React from 'react'
import ReactDOM from 'react-dom'
import UI from './react/index.js'
import Models from './models/index.js'
import t from './lib/i18n-translate.js'

window.$ = $
window.f = f
window.React = React
window.ReactDOM = ReactDOM
window.App = { UI, Models, t }
window.UI = UI
window.Models = Models
```

### 8.2 Fix `app/javascript/ujs/hashviz.js` (mixed ESM import + CJS export)

**Current file:**

```js
import $ from 'jquery'
import hashVizSVG from '../lib/hashviz-svg.js'

module.exports = () =>
  $('[data-hashviz-container]').each(function () {
    const $container = $(this)
    const name = $container.data('hashviz-container')
    const text = __guardMethod__(
      __guardMethod__($(`[data-hashviz-target=${name}]`), 'first', o1 => o1.first()),
      'text',
      o => o.text()
    )
    return __guardMethod__($container, 'html', o2 => o2.html(hashVizSVG(text)))
  })

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName)
  } else {
    return undefined
  }
}
```

**New file:**

```js
import $ from 'jquery'
import hashVizSVG from '../lib/hashviz-svg.js'

export default () =>
  $('[data-hashviz-container]').each(function () {
    const $container = $(this)
    const name = $container.data('hashviz-container')
    const text = __guardMethod__(
      __guardMethod__($(`[data-hashviz-target=${name}]`), 'first', o1 => o1.first()),
      'text',
      o => o.text()
    )
    return __guardMethod__($container, 'html', o2 => o2.html(hashVizSVG(text)))
  })

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName)
  } else {
    return undefined
  }
}
```

**Change:** `module.exports =` to `export default`.

### 8.3 Fix `app/javascript/application.js` (remove `require('global')`)

**Current line 30:**

```js
app.extend({
  config: require('global').APP_CONFIG
})
```

**New:**

```js
app.extend({
  config: globalThis.APP_CONFIG
})
```

The `global` npm package is unnecessary -- `globalThis.APP_CONFIG` (or just `APP_CONFIG` since it's a global) works in all environments.

### 8.4 Fix `app/javascript/embedded-view.js` (remove `require('global')`)

**Current line 16:**

```js
app.extend({ config: require('global').APP_CONFIG })
```

**New:**

```js
app.extend({ config: globalThis.APP_CONFIG })
```

### 8.5 Remove Sprockets directives from JS files

Several JS files have Sprockets directives in comments:

```js
//= depend_on 'translations.csv'
//= depend_on_asset 'translations.csv'
```

These are in:

- `app/javascript/application.js` (lines 7-8)
- `app/javascript/embedded-view.js` (lines 1-2)
- `app/javascript/react-server-side.js` (lines 1-2)
- `app/javascript/integration-testbed.js` (lines 6-7)

**Remove these lines.** They were Sprockets directives for cache invalidation. Vite handles this via `watchAdditionalPaths` in `config/vite.json` (configured in Step 1.3).

---

## Step 9: Update Build Scripts

### 9.1 Rewrite `package.json` scripts section

**Current:**

```json
"scripts": {
  "start": "npm run -s watch",
  "watch": "mkdir -p public/assets/bundles && npm run -s watch:app",
  "watch-all": "mkdir -p public/assets/bundles && npm run -s watch:app & npm run -s watch:app-embedded-view & npm run -s watch:server",
  "build": "mkdir -p public/assets/bundles && npm run -s build:app && npm run -s build:app-embedded-view && npm run -s build:server && npm run -s build:integration",
  "watch:app": "NODE_ENV=development watchify app/javascript/application.js -d -v -o public/assets/bundles/dev-bundle.js",
  "watch:app-embedded-view": "NODE_ENV=development watchify app/javascript/embedded-view.js -d -v -o public/assets/bundles/dev-bundle-embedded-view.js",
  "watch:server": "NODE_ENV=development watchify app/javascript/react-server-side.js -d -v -o public/assets/bundles/dev-bundle-react-server-side.js",
  "build:app": "NODE_ENV=production browserify app/javascript/application.js -v -o public/assets/bundles/bundle.js",
  "build:app-embedded-view": "NODE_ENV=production browserify app/javascript/embedded-view.js -v -o public/assets/bundles/bundle-embedded-view.js",
  "build:dev-app-embedded-view": "NODE_ENV=development browserify app/javascript/embedded-view.js -v -o public/assets/bundles/dev-bundle-embedded-view.js",
  "build:server": "NODE_ENV=production browserify app/javascript/react-server-side.js -v -o public/assets/bundles/bundle-react-server-side.js",
  "build:server:dev": "NODE_ENV=development browserify app/javascript/react-server-side.js -v -o public/assets/bundles/bundle-react-server-side.js",
  "build:integration": "NODE_ENV=production browserify app/javascript/integration-testbed.js -v -o public/assets/bundles/bundle-integration-testbed.js",
  "format": "prettier 'app/javascript/**/*.{js,jsx}' --write",
  "format:check": "prettier 'app/javascript/**/*.{js,jsx}' --check",
  "lint": "eslint 'app/javascript/**/*.{js,jsx}'",
  "lint:errors": "eslint --quiet 'app/javascript/**/*.{js,jsx}'",
  "lint:fix": "eslint --fix 'app/javascript/**/*.{js,jsx}'",
  "devtools": "NODE_ENV=development npm run -s build-devtools",
  "devtools-js": "NODE_ENV=development npm run -s build-devtools && node -r ./tmp/devtools.js",
  "build-devtools": "NODE_ENV=production npm run -s browserify -- app/javascript/developer-tools.js > tmp/devtools.js",
  "browserify": "browserify"
}
```

**New:**

```json
"scripts": {
  "start": "npm run dev",
  "dev": "bin/vite dev",
  "build": "bin/vite build && npm run build:ssr",
  "build:ssr": "vite build --config vite.config.ssr.ts",
  "build:ssr:dev": "NODE_ENV=development vite build --config vite.config.ssr.ts --mode development",
  "watch:ssr": "NODE_ENV=development vite build --config vite.config.ssr.ts --mode development --watch",
  "format": "prettier 'app/javascript/**/*.{js,jsx}' --write",
  "format:check": "prettier 'app/javascript/**/*.{js,jsx}' --check",
  "lint": "eslint 'app/javascript/**/*.{js,jsx}'",
  "lint:errors": "eslint --quiet 'app/javascript/**/*.{js,jsx}'",
  "lint:fix": "eslint --fix 'app/javascript/**/*.{js,jsx}'"
}
```

### 9.2 Development workflow (3 terminals)

```bash
# Terminal 1: Vite dev server (client bundles with HMR)
npm run dev

# Terminal 2: SSR bundle watcher (rebuilds when source changes)
npm run watch:ssr

# Terminal 3: Rails server
bin/rails server
```

### 9.3 Rewrite `bin/precompile-assets`

**Current file:**

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE}")" ; cd .. > /dev/null 2>&1 && pwd -P)"
cd $PROJECT_DIR

./bin/env/ruby-setup --quiet
./bin/env/nodejs-setup

export RAILS_ENV=production
export RAILS_LOG_LEVEL=debug
export SECRET_KEY_BASE_DUMMY=1
export DISABLE_SECRETS_STRENGTH_CHECK=true

# delete all files (except .git, .gitignore and dev bundles)
if [ -d "public/assets" ]; then
  find public/assets -type f -not -name ".git*" -and -not -name "dev-*" -exec rm -f {} +
fi

npm ci --ignore-scripts --no-audit

# build locale files
bin/translation-csv-to-locale-yamls

# bundle js
npm run -s build

# precompilation: js, css, fonts, images
bundle exec rake assets:precompile

# cleanup obsoletes
bundle exec rake assets:clean

# write README
echo "precompiled assets for <https://github.com/Madek/madek-webapp>" > public/assets/README.md
```

**New file:**

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE}")" ; cd .. > /dev/null 2>&1 && pwd -P)"
cd $PROJECT_DIR

./bin/env/ruby-setup --quiet
./bin/env/nodejs-setup

export RAILS_ENV=production
export RAILS_LOG_LEVEL=debug
export SECRET_KEY_BASE_DUMMY=1
export DISABLE_SECRETS_STRENGTH_CHECK=true

# Clean previous Vite builds
if [ -d "public/vite" ]; then
  rm -rf public/vite
fi
# Clean previous SSR bundles
if [ -d "public/assets/bundles" ]; then
  find public/assets/bundles -type f -name "bundle-react-server-side*" -exec rm -f {} +
fi
# Clean Sprockets assets (except .git and dev bundles)
if [ -d "public/assets" ]; then
  find public/assets -type f -not -name ".git*" -and -not -name "dev-*" -and -not -path "*/bundles/*" -exec rm -f {} +
fi

npm ci --ignore-scripts --no-audit

# build locale files
bin/translation-csv-to-locale-yamls

# Build client bundles (JS + CSS) with Vite
bin/vite build

# Build SSR bundle with Vite
npm run -s build:ssr

# Precompile remaining Sprockets assets (fonts, images)
bundle exec rake assets:precompile

# Cleanup obsolete Sprockets assets
bundle exec rake assets:clean

# write README
echo "precompiled assets for <https://github.com/Madek/madek-webapp>" > public/assets/README.md
```

---

## Step 10: Update Sprockets Configuration

Sprockets no longer handles JS or CSS. It only handles fonts, images, and locale files.

### 10.1 Simplify `config/initializers/assets.rb`

**Current file:**

```ruby
if Rails.env.development?
  puts "run `npm ci` to make sure `node_modules` are up to date..."
  system('npm ci')
end

Rails.application.config.assets.version = "1.0"
Rails.application.config.assets.gzip = false

# NOTE: sprockets is not used for bundling JS, hand it the prebundled files:
Rails.application.config.assets.paths.concat(
  Dir["#{Rails.root}/public/assets/bundles"])

Rails.application.config.assets.precompile << %w(
  bundle.js
  bundle-embedded-view.js
).map { |name| "#{Rails.env.development? ? 'dev-' : ''}#{name}" }
.concat(%w( bundle-react-server-side.js bundle-integration-testbed.js ))

# CSS
Rails.application.config.assets.precompile << %w(
  application.css
  application-contrasted.css
  embedded-view.css
  styleguide.css
)

# NOTE: Rails does not support *matchers* anymore, do it manually
precompile_assets_dirs = %w(fonts/)
Rails.application.config.assets.precompile << Proc.new do |filename, path|
  precompile_assets_dirs.any? {|dir| path =~ Regexp.new("app/assets/#{dir}") }
end

# handle & precompile asset imports from npm
Rails.application.config.assets.paths.concat(Dir[
  "#{Rails.root}/node_modules/@eins78/typopro-open-sans/dist",
  "#{Rails.root}/node_modules/font-awesome/fonts",
  "#{Rails.root}/node_modules"])

# precompile assets from npm (only needed for fonts)
Rails.application.config.assets.precompile.concat(Dir[
  "#{Rails.root}/node_modules/@eins78/typopro-open-sans/dist/*",
  "#{Rails.root}/node_modules/font-awesome/fonts/*"])

# handle config/locale/*.csv
Rails.application.config.assets.paths.concat(Dir["#{Rails.root}/config/locale"])
Rails.application.config.assets.precompile.concat(Dir["#{Rails.root}/config/locale/*.csv"])
```

**New file:**

```ruby
# Sprockets configuration
# NOTE: Sprockets now only handles fonts and images.
# JS and CSS are handled by Vite Ruby.

Rails.application.config.assets.version = "1.0"
Rails.application.config.assets.gzip = false

# SSR bundle path (Vite SSR build outputs here)
Rails.application.config.assets.paths.concat(
  Dir["#{Rails.root}/public/assets/bundles"])

# Fonts from app/assets/fonts/
precompile_assets_dirs = %w(fonts/)
Rails.application.config.assets.precompile << Proc.new do |filename, path|
  precompile_assets_dirs.any? { |dir| path =~ Regexp.new("app/assets/#{dir}") }
end

# Font assets from npm (if still served via Sprockets for non-Vite pages)
Rails.application.config.assets.paths.concat(Dir[
  "#{Rails.root}/node_modules/@eins78/typopro-open-sans/dist",
  "#{Rails.root}/node_modules/font-awesome/fonts"])

Rails.application.config.assets.precompile.concat(Dir[
  "#{Rails.root}/node_modules/@eins78/typopro-open-sans/dist/*",
  "#{Rails.root}/node_modules/font-awesome/fonts/*"])

# Locale CSV files
Rails.application.config.assets.paths.concat(Dir["#{Rails.root}/config/locale"])
Rails.application.config.assets.precompile.concat(Dir["#{Rails.root}/config/locale/*.csv"])
```

**Removed:**

- `npm ci` on dev startup (Vite handles its own dependency management)
- JS bundle precompile entries (`bundle.js`, `dev-bundle.js`, etc.)
- CSS precompile entries (`application.css`, `embedded-view.css`, etc.)
- `node_modules` added to Sprockets paths (not needed for Vite)

---

## Step 11: Clean Up Dependencies

### 11.1 Remove from `package.json` dependencies

```
"bulk-require"         -> REMOVE (replaced by import.meta.glob)
"global"               -> REMOVE (use globalThis)
"fs-extra"             -> REMOVE (was only used alongside brfs)
"check-dependencies"   -> REMOVE (if not used elsewhere)
```

### 11.2 Remove from `package.json` devDependencies

```
"browserify"              -> REMOVE
"browserify-incremental"  -> REMOVE
"watchify"                -> REMOVE
"babelify"                -> REMOVE
"bulkify"                 -> REMOVE
"brfs"                    -> REMOVE
"babel-polyfill"          -> REMOVE (Vite handles polyfills via @vitejs/plugin-react)
```

### 11.3 Remove from `package.json` config sections

**Remove the entire `"browserify"` block:**

```json
"browserify": {
  "transform": ["babelify", "bulkify", "brfs"],
  "ignore": ["crypto"]
}
```

**The `"babel"` block can stay** (Vite reads it via `@vitejs/plugin-react`):

```json
"babel": {
  "plugins": ["@babel/plugin-transform-runtime"],
  "presets": ["@babel/preset-env", "@babel/preset-react"]
}
```

**Alternatively**, move babel config into `vite.config.ts`'s React plugin options and remove the `"babel"` block from `package.json`. Either approach works.

### 11.4 Remove from `Gemfile`

```ruby
gem 'react-rails', '= 1.10.0'  -> REMOVE
gem 'sass'                       -> REMOVE (Vite uses sass-embedded)
gem 'sass-rails'                 -> REMOVE (Vite handles Sass directly)
gem 'uglifier'                   -> REMOVE (Vite handles minification)
```

**Keep:**

```ruby
gem 'execjs'          # Still needed for SSR
gem 'sprockets-rails' # Still needed for fonts/images
```

**Add:**

```ruby
gem 'vite_rails'
gem 'connection_pool'
```

### 11.5 Remove `react_component` helper references

Search the entire codebase for any remaining calls to `react_component()`:

```bash
grep -r "react_component" app/ config/ --include="*.rb" --include="*.haml" --include="*.erb"
```

All calls should go through the `react()` wrapper in `ui_helper.rb`. If any direct `react_component()` calls exist, they must be migrated to the new `react()` helper.

---

## Step 12: Handle Integration Testbed Bundle

The integration testbed (`app/javascript/integration-testbed.js`) is used for Capybara/Selenium tests. Add it as a Vite entrypoint.

### 12.1 Create `app/javascript/entrypoints/integration-testbed.js`

```js
import '../integration-testbed.js'
```

### 12.2 Update the integration testbed source

**In `app/javascript/integration-testbed.js`, remove Sprockets directives (lines 6-7):**

```js
//= depend_on 'translations.csv'
//= depend_on_asset 'translations.csv'
```

The rest of the file can stay as CommonJS -- Vite handles it.

---

## Step 13: Update ESLint Configuration

### 13.1 Update `eslint.config.mjs`

**Current globals:**

```js
globals: {
  ...globals.browser,
  ...globals.commonjs,
  $: 'readonly',
  APP_CONFIG: 'readonly',
  __dirname: 'readonly'
}
```

**New globals:**

```js
globals: {
  ...globals.browser,
  $: 'readonly',
  APP_CONFIG: 'readonly'
}
```

**Removed:**

- `...globals.commonjs` (no longer using CommonJS globals like `require`, `module`, `exports` -- though this is optional since some files still use CJS)
- `__dirname: 'readonly'` (no longer used after removing bulk-require)

**Note:** If some source files still use `require()` during the transition, keep `...globals.commonjs` until those files are converted.

---

## Step 14: Verification Checklist

Execute these checks after completing all steps.

### 14.1 Development mode

- [ ] `bin/vite dev` starts without errors on port 3036
- [ ] `npm run watch:ssr` builds the SSR bundle to `public/assets/bundles/dev-bundle-react-server-side.js`
- [ ] `bin/rails server` starts without errors
- [ ] Visit the homepage -- SSR HTML is in the page source (View Source should show rendered content inside `<div data-react-class="...">`)
- [ ] React hydrates without console errors (no "Expected server HTML to contain..." warnings)
- [ ] CSS is loaded and styles are applied correctly
- [ ] HMR works: edit a React component file, see it update without page reload
- [ ] Visit `/media_entries/:id/embedded` -- embedded view renders correctly
- [ ] Visit `/media_entries/:id/fullscreen` -- fullscreen view renders correctly
- [ ] Visit the dashboard -- sidebar layout renders correctly
- [ ] Add `?___norender` to a URL -- verify SSR is skipped, client-only render works
- [ ] Verify translations work (language switcher, translated strings)

### 14.2 Production build

- [ ] `npm run build` completes without errors (client + SSR)
- [ ] `bundle exec rake assets:precompile` completes without errors (fonts/images)
- [ ] `RAILS_ENV=production bin/rails server` starts and serves pages correctly
- [ ] Fingerprinted client assets are generated in `public/vite/`
- [ ] CSS is extracted to a separate file (not inline `<style>` tags)
- [ ] Source maps are generated
- [ ] SSR bundle exists at `public/assets/bundles/bundle-react-server-side.js`

### 14.3 Component registry integrity

Verify the `globToNested` utility produces the correct nested object structure. Test with these 54 component names used in `react()` calls across 79 view invocations:

**Must resolve from UI.Views.\*:**

- `Views.Dashboard`
- `Views.Base`
- `Views.BaseTmpReact`
- `Views.Search`
- `Views.ReleaseShow`
- `Views.PersonShow`
- `Views.PersonEdit`
- `Views.GroupShow`
- `Views.GroupSearch`
- `Views.CollectionShow`
- `Views.Sidebar`
- `Views.SelectCollectionModal`
- `Views.MediaEntryPrivacyStatusIcon`
- `Views.My.Uploader`
- `Views.My.CreateCollection`
- `Views.My.Settings`
- `Views.My.Tokens`
- `Views.My.TokenNewPage`
- `Views.My.TokenCreatedPage`
- `Views.My.ActivityStream`
- `Views.My.ClipboardBox`
- `Views.My.Notifications`
- `Views.MediaEntry.Index`
- `Views.MediaEntry.MediaEntryEmbedded`
- `Views.MediaEntry.MediaEntryEmbeddedImage`
- `Views.MediaEntry.MediaEntryBrowse`
- `Views.MediaEntry.Export`
- `Views.MediaEntry.MediaEntryPermissions` (if it exists; some might use `Views.Base` instead)
- `Views.Collection.Index`
- `Views.Collection.ResourceSelection`
- `Views.MediaResource.AskDelete`
- `Views.Shared.Share`
- `Views.Shared.CustomUrls`
- `Views.Shared.EditCustomUrls`
- `Views.Shared.ConfidentialLinks`
- `Views.Shared.ConfidentialLinkNew`
- `Views.Shared.ConfidentialLinkShow`
- `Views.Vocabularies.VocabulariesIndex`
- `Views.Vocabularies.VocabularyShow`
- `Views.Vocabularies.VocabularyContents`
- `Views.Vocabularies.VocabularyKeywords`
- `Views.Vocabularies.VocabularyPeople`
- `Views.Vocabularies.VocabularyPermissions`
- `Views.Vocabularies.VocabularyTerm`
- `Views.explore.ExploreCatalogCategoryPage`
- `Views.explore.ExploreKeywordsPage`
- `Views.explore.partials.ThumbnailResourceList`
- `Views.explore.partials.CatalogResourceList`
- `Views.batch.BatchResourcePermissions`

**Must resolve from UI.Deco.\*:**

- `Deco.ResourceMetaDataPagePerContext`
- `Deco.MediaResourcesBox`
- `Deco.ResourceThumbnail`
- `Deco.InputMetaDatum`
- `Deco.BatchAddToSet`
- `Deco.BatchRemoveFromSet`

**Must resolve from UI.App.\*:**

- `App.UserMenu`
- `App.LoginMenu`
- `App.TestLoginForm`

### 14.4 SSR correctness

- [ ] View page source -- server-rendered HTML appears inside `<div data-react-class="...">`
- [ ] No ExecJS errors in Rails server log
- [ ] SSR pool operates correctly under concurrent requests (production mode)
- [ ] SSR falls back gracefully if component is not found (logs error, renders empty)

### 14.5 Run existing test suite

- [ ] All Ruby tests pass (`bundle exec rspec` or equivalent)
- [ ] All JavaScript integration tests pass
- [ ] ESLint passes (`npm run lint`)
- [ ] Prettier passes (`npm run format:check`)

---

## Complete File Change Summary

### New files to CREATE

| File                                                     | Purpose                                                         |
| -------------------------------------------------------- | --------------------------------------------------------------- |
| `config/vite.json`                                       | Vite Ruby shared configuration                                  |
| `vite.config.ts`                                         | Vite client build configuration                                 |
| `vite.config.ssr.ts`                                     | Vite SSR build configuration                                    |
| `bin/vite`                                               | Vite CLI binstub (auto-generated by `bundle exec vite install`) |
| `app/javascript/entrypoints/application.js`              | Client entry: imports app CSS + existing bootstrap              |
| `app/javascript/entrypoints/embedded-view.js`            | Embedded view entry: imports embedded CSS + existing code       |
| `app/javascript/entrypoints/application-contrasted.sass` | High-contrast CSS entry                                         |
| `app/javascript/entrypoints/styleguide.sass`             | Styleguide CSS entry                                            |
| `app/javascript/entrypoints/integration-testbed.js`      | Test harness entry                                              |
| `app/javascript/lib/glob-to-nested.js`                   | Utility: converts import.meta.glob flat paths to nested objects |
| `app/javascript/react-server-side-vite.js`               | SSR bundle entry point (Vite version)                           |
| `app/lib/ssr_renderer.rb`                                | SSR renderer interface (swappable backend)                      |
| `app/lib/ssr_renderer/exec_js_backend.rb`                | ExecJS SSR backend (replaces react-rails)                       |
| `config/initializers/ssr.rb`                             | SSR auto-reload in development                                  |

### Files to MODIFY

| File                                          | What changes                                                                                      |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `Gemfile`                                     | Remove react-rails/sass/sass-rails/uglifier. Add vite_rails, connection_pool.                     |
| `package.json`                                | Remove browserify ecosystem. Add vite ecosystem. Rewrite scripts. Remove browserify config block. |
| `app/helpers/ui_helper.rb`                    | Rewrite `react()` method (lines 44-56) to use SsrRenderer                                         |
| `app/javascript/react/index.js`               | Replace bulk-require with import.meta.glob + globToNested                                         |
| `app/javascript/react/views/index.js`         | Replace bulk-require with import.meta.glob + globToNested                                         |
| `app/javascript/react/ui-components/index.js` | Replace bulk-require with import.meta.glob + globToFlat                                           |
| `app/javascript/models/index.js`              | Replace bulk-require with import.meta.glob                                                        |
| `app/javascript/lib/i18n-translate.js`        | Replace brfs with ?raw import. Fix mixed CJS/ESM.                                                 |
| `app/javascript/ujs/hashviz.js`               | Change `module.exports` to `export default`                                                       |
| `app/javascript/application.js`               | Remove `require('global')`, use `globalThis`. Remove Sprockets directives.                        |
| `app/javascript/embedded-view.js`             | Remove `require('global')`, use `globalThis`. Remove Sprockets directives.                        |
| `app/javascript/developer-tools.js`           | Replace `require('global')` with direct window assignments                                        |
| `app/javascript/integration-testbed.js`       | Remove Sprockets directives                                                                       |
| `app/views/layouts/_base.haml`                | Replace stylesheet/javascript*include_tag with vite*\*\_tag helpers                               |
| `app/views/layouts/_embedded.html.haml`       | Replace stylesheet/javascript*include_tag with vite*\*\_tag helpers                               |
| `app/views/layouts/_fullscreen.html.haml`     | Replace stylesheet/javascript*include_tag with vite*\*\_tag helpers                               |
| `app/assets/stylesheets/_fonts.scss`          | Replace asset-path() with direct node_modules relative paths                                      |
| `config/initializers/assets.rb`               | Remove JS/CSS precompile entries. Simplify to fonts/images only.                                  |
| `config/application.rb`                       | Remove react-rails config block (lines 94-114)                                                    |
| `config/environments/development.rb`          | Remove react-rails config (lines 85-92)                                                           |
| `config/environments/production.rb`           | Replace react pool config with config.x.ssr\_\* (lines 60-62)                                     |
| `bin/precompile-assets`                       | Rewrite to use bin/vite build + npm run build:ssr                                                 |
| `eslint.config.mjs`                           | Remove \_\_dirname and optionally commonjs globals                                                |

### Files NOT changed

- All 60 decorator components in `app/javascript/react/decorators/`
- All 91 view components in `app/javascript/react/views/` (except `index.js`)
- All 32 UI components in `app/javascript/react/ui-components/` (except `index.js`)
- All model files in `app/javascript/models/` (except `index.js`)
- All lib files in `app/javascript/lib/` (except `i18n-translate.js` and new `glob-to-nested.js`)
- All controller files
- All HAML view templates (except the 3 layouts)
- `app/javascript/ujs/react.js` (client-side hydration -- unchanged)
- `app/lib/frontend_app_config.rb` (unchanged)
- `config/puma.rb` (unchanged)
- `prettier.config.mjs` (unchanged)
- `.tool-versions` (unchanged)

### Files to DELETE (after verification)

| File                                  | Reason                                  |
| ------------------------------------- | --------------------------------------- |
| `app/javascript/react-server-side.js` | Replaced by `react-server-side-vite.js` |

---

## Risk Mitigation and Rollback Plan

### Keep Browserify as fallback during migration

During development, keep the old Browserify scripts under different names in `package.json`:

```json
"build:legacy": "mkdir -p public/assets/bundles && npm run -s build:legacy:app && ...",
"build:legacy:app": "NODE_ENV=production browserify app/javascript/application.js -v -o public/assets/bundles/bundle.js"
```

This way you can revert to Browserify by:

1. Restoring `react-rails` to Gemfile
2. Running `npm run build:legacy`
3. Reverting layout changes

### Test `globToNested` early

The `globToNested` utility is the highest-risk piece. Before integrating it, write a standalone test:

```js
// test-glob-to-nested.js (run with: node --experimental-vm-modules test-glob-to-nested.js)
import { globToNested } from './app/javascript/lib/glob-to-nested.js'

// Simulate import.meta.glob output
const mockModules = {
  './Base.jsx': { default: function Base() {} },
  './Dashboard.jsx': { default: function Dashboard() {} },
  './My/Uploader.jsx': { default: function Uploader() {} },
  './My/Settings.jsx': { default: function Settings() {} },
  './MediaEntry/Index.jsx': { default: function Index() {} }
}

const result = globToNested(mockModules)
console.log('Base:', typeof result.Base) // should be 'function'
console.log('My.Uploader:', typeof result.My?.Uploader) // should be 'function'
console.log('MediaEntry.Index:', typeof result.MediaEntry?.Index) // should be 'function'
```

### Incremental approach (recommended)

1. **Steps 1-4:** Get Vite building client bundles alongside Browserify. Test in a branch.
2. **Step 5:** Build custom SSR. Test SSR output matches react-rails output.
3. **Steps 6-7:** Switch layouts to Vite. This is the point of no return.
4. **Steps 8-11:** Clean up. Can be done gradually.

### Verify SSR bundle integrity

After building the SSR bundle, verify it works in isolation:

```bash
node -e "
  eval(require('fs').readFileSync('public/assets/bundles/bundle-react-server-side.js', 'utf8'));
  console.log('React:', typeof React);
  console.log('ReactDOMServer:', typeof ReactDOMServer);
  console.log('UI keys:', Object.keys(UI));
  console.log('UI.Views keys:', Object.keys(UI.Views));
  console.log('UI.Deco keys:', Object.keys(UI.Deco));
"
```

Expected output:

```
React: object
ReactDOMServer: object
UI keys: [ 'UI', 'Deco', 'Views', 'App' ]
UI.Views keys: [ 'Base', 'BaseTmpReact', 'Dashboard', 'My', 'MediaEntry', 'Collection', ... ]
UI.Deco keys: [ 'BatchAddToSet', 'MediaResourcesBox', 'ResourceThumbnail', ... ]
```

---

## Future Roadmap

This migration is Phase 1 of a 3-phase modernization:

```
Phase 1 (this plan):
  Browserify + react-rails + Sprockets(CSS) + React 16
    ↓
  Vite Ruby + custom SsrRenderer (ExecJS) + Vite(CSS) + React 16

Phase 2 (future):
  React 16 → React 18
  - ReactDOM.render() → createRoot()
  - Update react-bootstrap, react-day-picker, etc.
  - Update renderToString in SSR (still works in 18, just deprecated)

Phase 3 (optional, future):
  Swap ExecJS SSR backend → Node.js HTTP service
  - SsrRenderer::ExecJsBackend → SsrRenderer::NodeBackend
  - Enable streaming SSR with renderToPipeableStream
  - Better performance (Node.js is much faster than ExecJS)
```

### SSR Backend Swap (Phase 3 detail)

The `SsrRenderer` module is designed with a swappable backend. When ready, create:

```ruby
# app/lib/ssr_renderer/node_backend.rb
module SsrRenderer
  class NodeBackend
    def initialize
      @base_url = ENV.fetch('SSR_SERVICE_URL', 'http://localhost:3001')
    end

    def render(component_name, props)
      uri = URI("#{@base_url}/render")
      response = Net::HTTP.post(uri,
        { component: component_name, props: props }.to_json,
        'Content-Type' => 'application/json'
      )

      if response.code == '200'
        JSON.parse(response.body)['html']
      else
        Rails.logger.error("[SSR] Node service returned #{response.code}")
        ""
      end
    rescue => e
      Rails.logger.error("[SSR] Node service error: #{e.message}")
      ""
    end
  end
end
```

Then switch backends via config:

```ruby
# config/environments/production.rb
config.x.ssr_backend = :node

# app/lib/ssr_renderer.rb
def self.backend
  @backend ||= case Rails.configuration.x.ssr_backend
    when :node then NodeBackend.new
    else ExecJsBackend.new
  end
end
```

No view code changes needed. All 79 `react()` calls remain exactly the same.
