/* eslint-disable no-console */
/**
 * vite.config.client.mjs
 *
 * Vite 8 build + watch for client-side bundles using Rolldown (native Vite bundler).
 *   application.js            → bundle.js        (prod) / dev-bundle.js        (watch)
 *   embedded-view.js          → bundle-embedded-view.js
 *   integration-testbed.js    → bundle-integration-testbed.js
 */

import { defineConfig } from 'vite'
import { rolldown, watch as rolldownWatch } from 'rolldown'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import { sourceTransformPlugin } from './vite.shared/source-transform-plugin.mjs'
import { virtualNoopPlugin } from './vite.shared/virtual-noop-plugin.mjs'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// ---------------------------------------------------------------------------
// Common Rolldown options shared across all client bundles
// ---------------------------------------------------------------------------
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
    name: '_madek',
    sourcemap: isDev
  }
}

// ---------------------------------------------------------------------------
// Bundle entries
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
// Vite plugin: builds (or watches) all client bundles with Rolldown
// ---------------------------------------------------------------------------
function clientBundlesPlugin() {
  let isWatch = false
  let watchers = []

  return {
    name: 'client-bundles',
    apply: 'build',

    configResolved(config) {
      isWatch = !!config.build.watch
    },

    async closeBundle() {
      // eslint-disable-next-line no-undef
      const isDev = isWatch || process.env.NODE_ENV === 'development'

      if (isWatch) {
        if (watchers.length > 0) return // already watching
        console.log('\nWatching client bundles with Rolldown…')
        watchers = ENTRIES.map(e => {
          const watcher = rolldownWatch({
            input: e.input,
            ...commonRolldownOptions(true),
            output: outputOptions(e.devOut, true)
          })
          watcher.on('event', event => {
            if (event.code === 'ERROR') console.error('Rolldown watch error:', event.error)
            if (event.code === 'BUNDLE_END') {
              console.log('  rebuilt →', e.devOut.replace(__dirname + '/', ''))
              event.result?.close()
            }
          })
          console.log('  watching →', e.devOut.replace(__dirname + '/', ''))
          return watcher
        })
      } else {
        console.log('\nBuilding client bundles with Rolldown…')
        await Promise.all(
          ENTRIES.map(async e => {
            const bundle = await rolldown({
              input: e.input,
              ...commonRolldownOptions(isDev)
            })
            await bundle.write(outputOptions(isDev ? e.devOut : e.prodOut, isDev))
            await bundle.close()
            console.log('  →', (isDev ? e.devOut : e.prodOut).replace(__dirname + '/', ''))
          })
        )
      }
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
        if (warning.code === 'EMPTY_BUNDLE') return
        warn(warning)
      }
    },
    outDir: '/tmp/vite-client-noop',
    emptyOutDir: true,
    minify: false,
    write: false
  }
})
