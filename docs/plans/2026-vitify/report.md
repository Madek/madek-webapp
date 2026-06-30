# Vitify: Replacing Browserify with Vite + esbuild

- **Date:** 2026-06-29
- **Author:** Claude Sonnet 4.5 (github-copilot/claude-sonnet-4.6), via OpenCode

## Goal

Replace the legacy browserify/watchify build pipeline with a Vite + esbuild based pipeline
for all JS bundles: server-side SSR, client app, embedded-view, and integration testbed.

## Outcome

All four bundles are now built by Vite/esbuild. Browserify, watchify, babelify, brfs, and
bulkify have been removed from the project entirely. Build times are significantly faster.

---

## What was built

### Two Vite config files

**`vite.config.client.mjs`** — builds three client-side bundles in one esbuild pass:

| Entry | Production output | Dev/watch output |
|---|---|---|
| `app/javascript/application.js` | `bundle-vite.js` | `dev-bundle-vite.js` |
| `app/javascript/embedded-view.js` | `bundle-embedded-view-vite.js` | `dev-bundle-embedded-view-vite.js` |
| `app/javascript/integration-testbed.js` | `bundle-integration-testbed-vite.js` | `dev-bundle-integration-testbed-vite.js` |

**`vite.config.server.mjs`** — builds the server-side SSR bundle:

| Entry | Production output | Dev/watch output |
|---|---|---|
| `app/javascript/react-server-side.js` | `bundle-react-server-side-vite.js` | `dev-bundle-react-server-side-vite.js` |

Both configs use esbuild inside a Vite `closeBundle` plugin hook. Rollup (Vite's default
bundler) was not used because it cannot handle the mix of CJS `require()` and JSX in `.js`
files that the Madek source uses.

### Custom esbuild source-transform plugin

Both configs share a `sourceTransformPlugin` that runs four transforms on every source file
before esbuild sees it — replicating the old browserify transform chain:

1. **brfs** — inlines `require('fs').readFileSync(path.join(__dirname, ...))` calls at build
   time. Implemented inline (no dependency on the `brfs` npm package).

2. **bulkify** — expands `requireBulk(__dirname, [...])` calls into static `require()`
   statements. Implemented inline (no dependency on the `bulkify` npm package).

3. **mixedEsmCjs** — handles decaffeinate artifacts that contain both `export default X` and
   `module.exports = X` in the same file. esbuild treats such files as ESM and ignores
   `module.exports`; this step rewrites them to pure CJS so esbuild handles them correctly.
   Also compiles JSX in the same pass using `esbuild.transform`.

4. **shorthand-properties** — runs `@babel/plugin-transform-shorthand-properties` on all
   project source files (not `node_modules`). This converts object method shorthands
   (`{ foo() {} }`) to regular function expressions (`{ foo: function foo() {} }`).
   This is required because modern V8 (Node 22+) does not allow `new` on method shorthands,
   but Ampersand's `_prepareModel` does exactly that (`new this.model(attrs, options)`).
   `@babel/preset-react` is also included in this step for files where JSX has not yet been
   compiled (i.e., step 3 did not run).

### Additional esbuild plugins

- **tripleDotsResolvePlugin** — resolves `require('.../lib/foo')` paths (triple-dot relative
  paths). Only browserify's `resolve` module handled this convention; esbuild does not.

- **`global` and `require` stub banners (server bundle)** — ExecJS / mini_racer runs the
  server bundle in an isolated V8 context with no `global` and no `require`. A banner
  provides both: `global = globalThis` and a `require` stub that returns `{}` for known
  Node.js built-ins (`fs`, `net`, `crypto`) and throws for anything else.

### Rails configuration changes

- `config/application.rb` — SSR bundle filename updated to `-vite` variant.
- `config/environments/development.rb` — dev SSR bundle filename updated.
- `config/initializers/assets.rb` — all `-vite` bundle names added to the Sprockets
  precompile list.
- `app/views/layouts/_base.haml` — client bundle reference updated.
- `app/views/layouts/_fullscreen.html.haml` — embedded-view bundle reference updated.
- `app/views/layouts/_embedded.html.haml` — embedded-view bundle reference updated.
- `app/views/styleguide/00_Scratchpad/_draft.html.haml` — integration testbed bundle updated.

---

## What was removed

### npm scripts

Removed all browserify/watchify scripts: `build:app`, `build:app-embedded-view`,
`build:app-embedded-view:dev`, `build:server`, `build:server:dev`, `build:integration`,
`build-devtools`, `watch:app`, `watch:app-embedded-view`, `watch:server`, `browserify`,
`devtools`, `devtools-js`.

The `"browserify"` config block (transform list) was also removed from `package.json`.

### devDependencies removed

`babelify`, `babel-polyfill`, `brfs`, `browserify`, `browserify-incremental`, `bulkify`,
`watchify`.

### Bundle files removed

`public/assets/bundles/dev-bundle.js`, `dev-bundle-embedded-view.js`,
`dev-bundle-react-server-side.js`.

---

## Dependencies added

Packages that were previously only available transitively through browserify are now declared
explicitly:

| Package | Location | Reason |
|---|---|---|
| `@babel/core` | devDependencies | Required by the Babel step in `sourceTransformPlugin` |
| `@babel/plugin-transform-shorthand-properties` | devDependencies | Step 4 of `sourceTransformPlugin` |
| `fast-glob` | devDependencies | Used in both vite configs to expand bulk-require globs |
| `resolve` | devDependencies | Used by `tripleDotsResolvePlugin` |
| `url` | dependencies | Node.js `url` built-in polyfill; browserify shimmed this automatically |

---

## Key technical decisions

**esbuild inside Vite `closeBundle` hook, not Rollup**
Rollup + `@rollup/plugin-commonjs` conflicts with Vite's `vite:build-import-analysis` plugin
when source files mix CJS and JSX. esbuild handles both natively.

**Vite 5, not Vite 8**
Vite 8 uses Rolldown as bundler. Rolldown parses files before plugin transforms run, so
JSX in `.js` files (not `.jsx`) fails immediately. Vite 5 with esbuild does not have this
problem.

**`platform: 'browser'` + `format: 'iife'` for client bundles**
Produces a self-contained bundle with no global `require()`, required because Sprockets
serves these files without a module loader.

**`@babel/plugin-transform-shorthand-properties` instead of `target: 'es5'`**
esbuild's `target: 'es5'` cannot compile `for-of` loops, classes, etc. that appear
throughout the codebase. The Babel plugin is surgical: it only converts method shorthands to
function expressions, leaving all other syntax untouched.

**`mixedEsmCjs` step (step 3) for decaffeinate artifacts**
Files generated by decaffeinate often contain both `export default` and `module.exports`.
esbuild treats the file as ESM and silently drops `module.exports`. The step rewrites such
files to pure CJS before esbuild processes them.
