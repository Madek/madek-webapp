/**
 * vite.config.client.mjs
 *
 * Vite-based build + watch for both client-side bundles:
 *   application.js      → bundle.js        (prod) / dev-bundle.js        (watch)
 *   embedded-view.js    → bundle-embedded-view.js (prod) / dev-bundle-embedded-view.js (watch)
 *
 * Run modes:
 *   vite build          --config vite.config.client.mjs          (production build)
 *   vite build --watch  --config vite.config.client.mjs          (development watch)
 *
 * Same esbuild-based approach as vite.config.server.mjs, reusing the same
 * custom transforms (brfs, bulkify, mixed ESM+CJS, triple-dot paths).
 */

import { defineConfig } from 'vite'
import {
  build as esbuildBuild,
  context as esbuildContext,
  transform as esbuildTransform
} from 'esbuild'
import { resolve, dirname, basename, extname, join } from 'path'
import { readFileSync, promises as fsp } from 'fs'
import { fileURLToPath } from 'url'
import fg from 'fast-glob'
import resolveModule from 'resolve'
import { createRequire } from 'module'

const _require = createRequire(import.meta.url)
// Lazily resolve Babel so it is only loaded when needed
function getBabel() {
  return _require('@babel/core')
}

const { sync: globSync } = fg

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// ---------------------------------------------------------------------------
// esbuild plugin: fix non-standard '...' paths (same as server config)
// ---------------------------------------------------------------------------
const tripleDotsResolvePlugin = {
  name: 'triple-dots-resolve',
  setup(build) {
    build.onResolve({ filter: /\.\.\./ }, args => {
      return new Promise(resolvePromise => {
        resolveModule(
          args.path,
          { basedir: args.resolveDir || dirname(args.importer) },
          (err, resolved) => {
            if (err) resolvePromise({ errors: [{ text: err.message }] })
            else resolvePromise({ path: resolved })
          }
        )
      })
    })
  }
}

// ---------------------------------------------------------------------------
// Helper: expand bulk-require calls (same as server config)
// ---------------------------------------------------------------------------
function expandBulkRequire(dir, patterns) {
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
    if (typeof obj === 'string') return `require(${JSON.stringify(obj)})`
    const entries = Object.entries(obj).map(([k, v]) => `${JSON.stringify(k)}: ${serialize(v)}`)
    return `({ ${entries.join(', ')} })`
  }

  return serialize(root)
}

// ---------------------------------------------------------------------------
// esbuild plugin: combined source transform (same as server config)
//   1. brfs:        inline fs.readFileSync at build time
//   2. bulkify:     expand requireBulk(__dirname, [...]) calls
//   3. mixedEsmCjs: convert mixed ESM+CJS files to pure CJS
// ---------------------------------------------------------------------------
const sourceTransformPlugin = {
  name: 'source-transform',
  setup(build) {
    build.onLoad({ filter: /\.(jsx?)$/ }, async args => {
      let code = await fsp.readFile(args.path, 'utf8')
      const fileDir = dirname(args.path)
      let changed = false

      // ── 1. brfs ───────────────────────────────────────────────────────────
      if (code.includes('readFileSync')) {
        const brfsRegex =
          /require\(['"]fs['"]\)\.readFileSync\(\s*(?:require\(['"]path['"]\)\.join|path\.join)\s*\(\s*__dirname\s*,\s*(['"][^'"]+['"])\s*\)\s*,\s*['"]utf8['"]\s*\)/gs

        const inlined = code.replace(brfsRegex, (_match, relPathStr) => {
          const relPath = relPathStr.replace(/^['"]|['"]$/g, '')
          return JSON.stringify(readFileSync(join(fileDir, relPath), 'utf8'))
        })
        if (inlined !== code) {
          code = inlined
          changed = true
          // Remove now-unused `var path = require('path')`
          code = code.replace(/\bvar\s+path\s*=\s*require\(['"]path['"]\);?\s*\n?/g, '')
        }
      }

      // ── 2. bulkify ────────────────────────────────────────────────────────
      if (code.includes('bulk-require')) {
        let bulked = code

        const callRegex = /requireBulk\s*\(\s*__dirname\s*,\s*(\[[\s\S]*?\])\s*\)/g
        bulked = bulked.replace(callRegex, (_match, patternsStr) => {
          const patterns = Array.from(patternsStr.matchAll(/['"]([^'"]+)['"]/g), m => m[1])
          return expandBulkRequire(fileDir, patterns)
        })
        bulked = bulked.replace(
          /(?:const|var|let)\s+requireBulk\s*=\s*require\(['"]bulk-require['"]\)\s*\n?/g,
          '// (bulk-require removed)\n'
        )
        bulked = bulked.replace(
          /import\s+requireBulk\s+from\s+['"]bulk-require['"]\s*\n?/g,
          '// (bulk-require removed)\n'
        )
        if (bulked !== code) {
          code = bulked
          changed = true
        }
      }

      // ── 3. mixedEsmCjs ───────────────────────────────────────────────────
      const hasCjsExports = /\bmodule\.exports\b/.test(code)
      const hasEsmSyntax = /(?:^|\n)\s*(?:import\s|export\s)/.test(code)

      if (hasCjsExports && hasEsmSyntax) {
        const ext = args.path.endsWith('.jsx') ? 'jsx' : 'js'
        const result = await esbuildTransform(code, {
          loader: ext,
          format: 'cjs',
          jsx: 'transform',
          jsxFactory: 'React.createElement',
          jsxFragment: 'React.Fragment',
          target: 'es2015'
        })
        code = result.code
        changed = true
      }

      // ── 4. shorthand-properties ──────────────────────────────────────────
      // ES2022+ engines (and modern V8) do not allow `new` on object literal
      // method shorthands (`foo() {}`). Ampersand collections call
      // `new this.model(attrs)`, so the `model` property must be a regular
      // function expression. Babel's shorthand-properties plugin converts
      // `{ foo(a) {} }` → `{ foo: function foo(a) {} }` without touching
      // any other modern syntax.
      if (args.path.includes('/node_modules/')) {
        // skip node_modules — they don't use the Ampersand extend pattern
      } else {
        const babel = getBabel()
        const babelResult = babel.transformSync(code, {
          filename: args.path,
          configFile: false,
          babelrc: false,
          plugins: ['@babel/plugin-transform-shorthand-properties'],
          // Include @babel/preset-react if JSX has NOT been compiled yet
          // (i.e., step 3 did not run). This covers .js files that contain JSX.
          presets: !changed
            ? [
                [
                  '@babel/preset-react',
                  { pragma: 'React.createElement', pragmaFrag: 'React.Fragment' }
                ]
              ]
            : []
        })
        if (babelResult && babelResult.code !== code) {
          code = babelResult.code
          changed = true
        }
      }

      if (!changed) return undefined
      return { contents: code, loader: 'js' }
    })
  }
}

// ---------------------------------------------------------------------------
// Common esbuild options shared across all client bundles
// ---------------------------------------------------------------------------
function commonEsbuildOptions(isDev) {
  return {
    bundle: true,
    platform: 'browser',
    format: 'iife',
    loader: { '.js': 'jsx', '.jsx': 'jsx' },
    jsxFactory: 'React.createElement',
    jsxFragment: 'React.Fragment',
    define: { 'process.env.NODE_ENV': isDev ? '"development"' : '"production"' },
    // Stub Node.js built-ins that have no browser equivalent.
    // These appear in npm dependencies (babyparse uses fs, some use net/crypto)
    // but are never actually called during browser rendering.
    external: ['crypto', 'fs', 'net'],
    banner: {
      js: [
        'var require = (function(origRequire) {',
        '  var stubs = { fs: {}, net: {}, crypto: {} };',
        '  return function require(id) {',
        '    if (id in stubs) return stubs[id];',
        '    if (typeof origRequire === "function") return origRequire(id);',
        '    throw new Error("require not available: " + id);',
        '  };',
        '})(typeof require !== "undefined" ? require : undefined);'
      ].join('\n')
    },
    plugins: [tripleDotsResolvePlugin, sourceTransformPlugin],
    sourcemap: isDev,
    minify: false
  }
}

// ---------------------------------------------------------------------------
// Bundle entries: [entry, prodOutfile, devOutfile]
// ---------------------------------------------------------------------------
const ENTRIES = [
  {
    input: resolve(__dirname, 'app/javascript/application.js'),
    prodOut: resolve(__dirname, 'public/assets/bundles/bundle.js'),
    devOut: resolve(__dirname, 'public/assets/bundles/dev-bundle.js')
  },
  {
    input: resolve(__dirname, 'app/javascript/embedded-view.js'),
    prodOut: resolve(__dirname, 'public/assets/bundles/bundle-embedded-view.js'),
    devOut: resolve(__dirname, 'public/assets/bundles/dev-bundle-embedded-view.js')
  },
  {
    input: resolve(__dirname, 'app/javascript/integration-testbed.js'),
    prodOut: resolve(__dirname, 'public/assets/bundles/bundle-integration-testbed.js'),
    devOut: resolve(__dirname, 'public/assets/bundles/dev-bundle-integration-testbed.js')
  }
]

// ---------------------------------------------------------------------------
// Vite plugin: builds (or watches) all client bundles with esbuild
// ---------------------------------------------------------------------------
function clientBundlesPlugin() {
  let isWatch = false
  let esbuildCtxs = []

  return {
    name: 'client-bundles',
    apply: 'build',

    configResolved(config) {
      isWatch = !!config.build.watch
    },

    async closeBundle() {
      const isDev = isWatch || process.env.NODE_ENV === 'development'

      // In watch mode, start the esbuild watchers once and let them run.
      if (isWatch) {
        if (esbuildCtxs.length > 0) return // already watching
        const opts = commonEsbuildOptions(true)
        esbuildCtxs = await Promise.all(
          ENTRIES.map(e => esbuildContext({ ...opts, entryPoints: [e.input], outfile: e.devOut }))
        )
        await Promise.all(esbuildCtxs.map(ctx => ctx.watch()))
        console.log('\nWatching client bundles with esbuild…')
        ENTRIES.forEach(e => console.log('  →', e.devOut.replace(__dirname + '/', '')))
      } else {
        // One-shot build (production or dev) of all bundles in parallel
        const opts = commonEsbuildOptions(isDev)
        console.log('\nBuilding client bundles with esbuild…')
        await Promise.all(
          ENTRIES.map(e =>
            esbuildBuild({
              ...opts,
              entryPoints: [e.input],
              outfile: isDev ? e.devOut : e.prodOut
            })
          )
        )
        ENTRIES.forEach(e =>
          console.log('  →', (isDev ? e.devOut : e.prodOut).replace(__dirname + '/', ''))
        )
      }
    },

    async buildEnd() {
      // On normal (non-watch) Rollup build end: nothing to clean up.
      // On watch mode shutdown (Vite process exit), dispose esbuild contexts.
      if (!isWatch) return
    }
  }
}

// ---------------------------------------------------------------------------
// Vite config
// ---------------------------------------------------------------------------
export default defineConfig({
  publicDir: false,
  plugins: [
    clientBundlesPlugin(),
    {
      name: 'virtual-noop',
      resolveId(id) {
        if (id === 'virtual:noop') return id
      },
      load(id) {
        if (id === 'virtual:noop') return 'export default {}'
      }
    }
  ],
  build: {
    rollupOptions: {
      input: 'virtual:noop',
      output: { format: 'esm' },
      onwarn(warning, warn) {
        // Suppress the expected "empty chunk" warning for the virtual no-op entry
        if (warning.code === 'EMPTY_BUNDLE') return
        warn(warning)
      }
    },
    // Redirect Rollup's (empty) output to a throwaway temp dir so it never
    // pollutes public/assets/bundles/ (important in --watch mode where
    // build.write:false is ignored by Vite).
    outDir: '/tmp/vite-client-noop',
    emptyOutDir: true,
    minify: false,
    write: false
  }
})
