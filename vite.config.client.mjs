/**
 * vite.config.client.mjs
 *
 * Vite-based build + watch for both client-side bundles:
 *   application.js      → bundle-vite.js        (prod) / dev-bundle-vite.js        (watch)
 *   embedded-view.js    → bundle-embedded-view-vite.js (prod) / dev-bundle-embedded-view-vite.js (watch)
 *
 * Run modes:
 *   vite build          --config vite.config.client.mjs          (production build)
 *   vite build --watch  --config vite.config.client.mjs          (development watch)
 *
 * Same esbuild-based approach as vite.config.server.mjs, reusing the same
 * custom transforms (brfs, bulkify, mixed ESM+CJS, triple-dot paths).
 */

import { defineConfig } from 'vite'
import { build as esbuildBuild, context as esbuildContext, transform as esbuildTransform } from 'esbuild'
import { resolve, dirname, basename, extname, join } from 'path'
import { readFileSync, promises as fsp } from 'fs'
import { fileURLToPath } from 'url'
import fg from 'fast-glob'
import resolveModule from 'resolve'

const { sync: globSync } = fg

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// ---------------------------------------------------------------------------
// esbuild plugin: fix non-standard '...' paths (same as server config)
// ---------------------------------------------------------------------------
const tripleDotsResolvePlugin = {
  name: 'triple-dots-resolve',
  setup(build) {
    build.onResolve({ filter: /\.\.\./ }, (args) => {
      return new Promise((resolvePromise) => {
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
  },
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
    build.onLoad({ filter: /\.(jsx?)$/ }, async (args) => {
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
        if (bulked !== code) { code = bulked; changed = true }
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
          target: 'es2015',
        })
        code = result.code
        changed = true
      }

      if (!changed) return undefined
      return { contents: code, loader: 'js' }
    })
  },
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
        '})(typeof require !== "undefined" ? require : undefined);',
      ].join('\n'),
    },
    plugins: [tripleDotsResolvePlugin, sourceTransformPlugin],
    sourcemap: isDev,
    minify: false,
  }
}

// ---------------------------------------------------------------------------
// Bundle entries: [entry, prodOutfile, devOutfile]
// ---------------------------------------------------------------------------
const ENTRIES = [
  {
    input: resolve(__dirname, 'app/javascript/application.js'),
    prodOut: resolve(__dirname, 'public/assets/bundles/bundle-vite.js'),
    devOut:  resolve(__dirname, 'public/assets/bundles/dev-bundle-vite.js'),
  },
  {
    input: resolve(__dirname, 'app/javascript/embedded-view.js'),
    prodOut: resolve(__dirname, 'public/assets/bundles/bundle-embedded-view-vite.js'),
    devOut:  resolve(__dirname, 'public/assets/bundles/dev-bundle-embedded-view-vite.js'),
  },
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
      // In watch mode, start the esbuild watchers once and let them run.
      if (isWatch) {
        if (esbuildCtxs.length > 0) return  // already watching
        const opts = commonEsbuildOptions(true)
        esbuildCtxs = await Promise.all(
          ENTRIES.map(e => esbuildContext({ ...opts, entryPoints: [e.input], outfile: e.devOut }))
        )
        await Promise.all(esbuildCtxs.map(ctx => ctx.watch()))
        console.log('\nWatching client bundles with esbuild…')
        ENTRIES.forEach(e => console.log('  →', e.devOut.replace(__dirname + '/', '')))
      } else {
        // One-shot production build of all bundles in parallel
        console.log('\nBuilding client bundles with esbuild…')
        const opts = commonEsbuildOptions(false)
        await Promise.all(
          ENTRIES.map(e => esbuildBuild({ ...opts, entryPoints: [e.input], outfile: e.prodOut }))
        )
        ENTRIES.forEach(e => console.log('  →', e.prodOut.replace(__dirname + '/', '')))
      }
    },

    async buildEnd() {
      // On normal (non-watch) Rollup build end: nothing to clean up.
      // On watch mode shutdown (Vite process exit), dispose esbuild contexts.
      if (!isWatch) return
    },
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
      resolveId(id) { if (id === 'virtual:noop') return id },
      load(id) { if (id === 'virtual:noop') return 'export default {}' },
    },
  ],
  build: {
    rollupOptions: {
      input: 'virtual:noop',
      output: { format: 'esm' },
    },
    // Redirect Rollup's (empty) output to a throwaway temp dir so it never
    // pollutes public/assets/bundles/ (important in --watch mode where
    // build.write:false is ignored by Vite).
    outDir: '/tmp/vite-client-noop',
    emptyOutDir: true,
    minify: false,
    write: false,
  },
})
