# Rollup Migration Status

**Date:** 2026-06-30

## Summary

After cleaning up the CJS/ESM mixed export patterns in the codebase, we attempted to switch from the esbuild-bypass approach to native Rollup bundling. The attempt is **blocked** by CJS-only npm dependencies.

## What Was Fixed

### Mixed Export Patterns (127 files)

Files that had both `export default X` and `module.exports = X` on consecutive lines were cleaned up by removing the duplicate `module.exports` line.

**Before:**
```javascript
import React from 'react'
const MyComponent = () => { ... }
export default MyComponent
module.exports = MyComponent  // duplicate!
```

**After:**
```javascript
import React from 'react'
const MyComponent = () => { ... }
export default MyComponent
```

### Mixed Import/Export Patterns (91 files)

Files that used ESM `import` statements but CJS `module.exports` for exports were converted to use `export default`.

**Before:**
```javascript
import f from 'active-lodash'
import Model from 'ampersand-model'

module.exports = Model.extend({ ... })
```

**After:**
```javascript
import f from 'active-lodash'
import Model from 'ampersand-model'

export default Model.extend({ ... })
```

### Named Export Issues

Several files attached named exports as properties on the default export, which doesn't work with ESM named imports. These were fixed by adding explicit named exports.

**Before:**
```javascript
const MyComponent = () => { ... }
export default MyComponent
MyComponent.SubComponent = SubComponent  // Not a named export!
```

**After:**
```javascript
const MyComponent = () => { ... }
export { SubComponent }  // Named export
export default MyComponent
MyComponent.SubComponent = SubComponent  // Keep for backward compat
```

Files fixed:
- `Dropdown.jsx` - `Menu`, `MenuItem`
- `ui.js` - `t`, `cx`, `parseMods`
- `resource-type-switcher.jsx` - `resourceTypeSwitcher`, `urlByType`
- `ConfidentialLinks.jsx` - `ConfidentialLinkHead`, `ConfidentialLinkRow`
- `mediaResourcesBoxState/state.js` - `nextState`
- `mediaResourcesBoxState/dataFetchers.js` - `fetchPage`, `fetchListMetadata`

### ESM Interop in bulk-require

Updated `expand-bulk-require.mjs` to wrap require calls with an interop helper that extracts `.default` from ESM modules:

```javascript
// Before
require("./decorators/BatchAddToSet.jsx")

// After
(function(m) { return m && m.__esModule ? m.default : m; })(require("./decorators/BatchAddToSet.jsx"))
```

## Rollup Blocker: CJS-Only Dependencies

When attempting to build with Rollup, we hit errors with npm packages that only provide CJS exports:

### `active-lodash`

```
"merge" is not exported by "node_modules/active-lodash/dist/index.js"
```

The codebase uses named imports:
```javascript
import { isString, isObject, merge, reduce, set } from 'active-lodash'
```

But `active-lodash` is compiled with Babel's old CJS interop and doesn't expose proper ESM named exports. Rollup's `@rollup/plugin-commonjs` cannot automatically detect these exports.

### `global/window`

```
"File" is not exported by "node_modules/global/window.js"
```

The package exports the global `window` object via `module.exports = win`, but code tries to destructure from it:
```javascript
import { File as BrowserFile } from 'global/window'
```

This was fixed by changing to:
```javascript
import globalWindow from 'global/window'
const BrowserFile = globalWindow.File
```

## Options to Enable Rollup

### Option 1: Replace `active-lodash` with `lodash-es`

`lodash-es` provides native ESM exports. Would require updating all imports:

```javascript
// Before
import f from 'active-lodash'
import { merge } from 'active-lodash'

// After
import merge from 'lodash-es/merge'
import isString from 'lodash-es/isString'
// etc.
```

**Effort:** High - many files to update, need to verify `active-lodash` additions like `present`, `presence`, `getPath` are available or need custom implementation.

### Option 2: Convert named imports to default imports

Change all destructuring imports to use the default export:

```javascript
// Before
import { merge, isString } from 'active-lodash'

// After
import f from 'active-lodash'
const { merge, isString } = f
```

**Effort:** Medium - scripted find/replace, but loses static analysis benefits.

### Option 3: Create ESM wrapper modules

Create wrapper modules in the project that re-export CJS modules:

```javascript
// lib/active-lodash-esm.js
import f from 'active-lodash'
export const merge = f.merge
export const isString = f.isString
// etc.
export default f
```

**Effort:** Medium - need to maintain wrapper, but minimal changes to consuming code.

### Option 4: Use Vite's optimizeDeps

Vite can pre-bundle CJS dependencies into ESM during dev. For production builds, this might help:

```javascript
// vite.config.js
export default {
  optimizeDeps: {
    include: ['active-lodash', 'global/window']
  }
}
```

**Effort:** Low - but may not work for all cases in production builds.

## Current Status

| Build Type | Status |
|------------|--------|
| esbuild (client) | ✅ Working |
| esbuild (server) | ✅ Working |
| Rollup (experimental) | ❌ Blocked |

The esbuild approach works well and handles CJS/ESM interop more flexibly. Rollup would enable better tree-shaking and potentially smaller bundles, but requires addressing the CJS dependency issues first.

## Recommendation

Keep the esbuild-based build for now. If bundle size becomes a concern, pursue **Option 1** (replace `active-lodash` with `lodash-es`) as part of a larger modernization effort, which would also improve tree-shaking.
