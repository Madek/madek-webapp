/* eslint-disable no-console */
/**
 * vite.config.server.mjs
 *
 * Vite 8 build for the server-side React bundle (ExecJS / mini_racer).
 * Bundling is done by Rolldown via the programmatic API.
 *
 * The banner defines `global` and stubs `require` for the V8 runtime context
 * that ExecJS uses (no window, no Node.js require).
 */

import { defineConfig } from 'vite'
import { rolldown, watch as rolldownWatch } from 'rolldown'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import { sourceTransformPlugin } from './vite.shared/source-transform-plugin.mjs'
import { virtualNoopPlugin } from './vite.shared/virtual-noop-plugin.mjs'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const ENTRY = resolve(__dirname, 'app/javascript/react-server-side.js')

// ExecJS runs in a bare V8 context: no `window`, no `global`, no `require`.
// This banner provides the minimal shims the bundle needs.
const SERVER_BANNER = [
  'var global = typeof globalThis !== "undefined" ? globalThis : (typeof window !== "undefined" ? window : this);',
  'var require = (function() {',
  '  var stubs = { fs: {}, net: {}, crypto: {} };',
  '  return function require(id) {',
  '    if (id in stubs) return stubs[id];',
  '    throw new Error("require not available: " + id);',
  '  };',
  '})();'
].join('\n')

function commonRolldownOptions(isDev) {
  return {
    plugins: [sourceTransformPlugin(isDev)],
    resolve: {
      alias: {
        crypto: resolve(__dirname, 'vite.shared/stubs/crypto.js'),
        fs: resolve(__dirname, 'vite.shared/stubs/fs.js'),
        net: resolve(__dirname, 'vite.shared/stubs/net.js')
      }
    }
  }
}

function outputOptions(outfile, isDev) {
  return {
    file: outfile,
    format: 'iife',
    name: '_madekServer',
    banner: SERVER_BANNER,
    sourcemap: isDev
  }
}

// ---------------------------------------------------------------------------
// Vite plugin: builds (or watches) the server bundle with Rolldown
// ---------------------------------------------------------------------------
function serverBundlePlugin() {
  let isWatch = false
  let watcher = null

  return {
    name: 'server-bundle',
    apply: 'build',

    configResolved(config) {
      isWatch = !!config.build.watch
    },

    async closeBundle() {
      // eslint-disable-next-line no-undef
      const isDev = isWatch || process.env.NODE_ENV === 'development'
      const prodOut = resolve(__dirname, 'public/assets/bundles/bundle-react-server-side.js')
      const devOut = resolve(__dirname, 'public/assets/bundles/dev-bundle-react-server-side.js')
      const outfile = isDev ? devOut : prodOut

      if (isWatch) {
        if (watcher) return // already watching
        console.log('\nWatching server-side bundle with Rolldown…')
        watcher = rolldownWatch({
          input: ENTRY,
          ...commonRolldownOptions(true),
          output: outputOptions(devOut, true)
        })
        watcher.on('event', event => {
          if (event.code === 'ERROR') console.error('Rolldown watch error:', event.error)
          if (event.code === 'BUNDLE_END') {
            console.log('  rebuilt →', devOut.replace(__dirname + '/', ''))
            event.result?.close()
          }
        })
        console.log('  watching →', devOut.replace(__dirname + '/', ''))
      } else {
        console.log('\nBuilding server-side bundle with Rolldown…')
        const bundle = await rolldown({
          input: ENTRY,
          ...commonRolldownOptions(isDev)
        })
        await bundle.write(outputOptions(outfile, isDev))
        await bundle.close()
        console.log('  →', outfile.replace(__dirname + '/', ''))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Vite config
// ---------------------------------------------------------------------------
export default defineConfig({
  publicDir: false,
  plugins: [serverBundlePlugin(), virtualNoopPlugin],
  build: {
    rollupOptions: {
      input: 'virtual:noop',
      output: { format: 'cjs', inlineDynamicImports: true },
      onwarn(warning, warn) {
        if (warning.code === 'EMPTY_BUNDLE') return
        warn(warning)
      }
    },
    outDir: '/tmp/vite-server-noop',
    emptyOutDir: true,
    minify: false,
    write: false
  }
})
