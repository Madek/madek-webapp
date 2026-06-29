/* eslint-disable no-console */
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
 * custom transforms (brfs, bulkify, mixed ESM+CJS).
 */

import { defineConfig } from 'vite'
import { build as esbuildBuild, context as esbuildContext } from 'esbuild'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import { sourceTransformPlugin } from './vite.shared/source-transform-plugin.mjs'
import { virtualNoopPlugin } from './vite.shared/virtual-noop-plugin.mjs'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

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
        'var require = (function() {',
        '  var stubs = { fs: {}, net: {}, crypto: {} };',
        '  return function require(id) {',
        '    if (id in stubs) return stubs[id];',
        '    throw new Error("require not available: " + id);',
        '  };',
        '})();'
      ].join('\n')
    },
    plugins: [sourceTransformPlugin],
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
      // eslint-disable-next-line no-undef
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
  plugins: [clientBundlesPlugin(), virtualNoopPlugin],
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
