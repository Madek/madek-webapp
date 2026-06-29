/* eslint-disable no-console */
/**
 * vite.config.server.mjs
 *
 * Vite-based build for the server-side React bundle.
 * The actual bundling is done by esbuild (which is bundled with Vite) via a
 * custom plugin. esbuild handles CJS, JSX, and full dependency bundling in one
 * pass — avoiding the Rollup + @rollup/plugin-commonjs + JSX compatibility
 * issues that arise when the source uses CJS require() with JSX in .js files.
 *
 * Custom esbuild plugins replicate the two remaining browserify transforms:
 *   - brfs:    inlines require('fs').readFileSync(...) calls at build time
 *   - bulkify: expands requireBulk(__dirname, [...]) calls into static requires
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
// Vite plugin: runs the esbuild bundle as part of `vite build`
// Supports:
//   - production build  → bundle-react-server-side.js
//   - dev one-shot build (NODE_ENV=development) → dev-bundle-react-server-side.js
//   - watch mode (--watch)  → dev-bundle-react-server-side.js + source maps
// ---------------------------------------------------------------------------
function serverBundlePlugin() {
  let isWatch = false
  let esbuildCtx = null

  return {
    name: 'server-bundle',
    apply: 'build',

    configResolved(config) {
      isWatch = !!config.build.watch
    },

    // Run AFTER Vite has finished its own (no-op) build
    async closeBundle() {
      // eslint-disable-next-line no-undef
      const isDev = isWatch || process.env.NODE_ENV === 'development'
      const outfile = resolve(
        __dirname,
        isDev
          ? 'public/assets/bundles/dev-bundle-react-server-side.js'
          : 'public/assets/bundles/bundle-react-server-side.js'
      )

      const esbuildOptions = {
        entryPoints: [resolve(__dirname, 'app/javascript/react-server-side.js')],
        bundle: true,
        // 'browser' platform: esbuild bundles/shims all Node.js built-ins (path, url,
        // util, stream, buffer …) so that no `require()` calls remain in the output.
        // This is required because ExecJS runs the bundle in an isolated context
        // without a global `require`.
        platform: 'browser',
        // IIFE: self-contained, auto-executing wrapper — exactly like the
        // browserify output. No exports, no require(), nothing leaks out.
        format: 'iife',
        outfile,
        // Treat .js files as JSX (some source files use JSX with a .js extension)
        loader: { '.js': 'jsx', '.jsx': 'jsx' },
        // Use the classic React.createElement pragma (React 16, matches browserify build)
        jsxFactory: 'React.createElement',
        jsxFragment: 'React.Fragment',
        define: { 'process.env.NODE_ENV': isDev ? '"development"' : '"production"' },
        // Define `global` for ExecJS (no window/global in V8 runtimes like mini_racer).
        // Provide a minimal `require` stub for Node.js built-ins that have no browser
        // shim in esbuild (`fs`, `net`) so `require()` calls in npm dependencies
        // like babyparse don't crash at parse time.
        banner: {
          js: [
            'var global = typeof globalThis !== "undefined" ? globalThis : (typeof window !== "undefined" ? window : this);',
            'var require = (function() {',
            '  var stubs = { fs: {}, net: {}, crypto: {} };',
            '  return function require(id) {',
            '    if (id in stubs) return stubs[id];',
            '    throw new Error("require not available: " + id);',
            '  };',
            '})();'
          ].join('\n')
        },
        // crypto is explicitly ignored by the existing browserify build.
        // fs and net have no browser shim in esbuild; they are handled by the
        // require stub in the banner above.
        external: ['crypto', 'fs', 'net'],
        plugins: [sourceTransformPlugin],
        sourcemap: isDev,
        minify: false
      }

      if (isWatch) {
        if (esbuildCtx) return // already watching
        console.log('\nWatching server-side bundle with esbuild…')
        esbuildCtx = await esbuildContext(esbuildOptions)
        await esbuildCtx.watch()
        console.log('  →', outfile.replace(__dirname + '/', ''))
      } else {
        console.log('\nBuilding server-side bundle with esbuild…')
        await esbuildBuild(esbuildOptions)
        console.log('  →', outfile.replace(__dirname + '/', ''))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Vite config — minimal, just a vehicle to run the esbuild bundle plugin
// ---------------------------------------------------------------------------
export default defineConfig({
  publicDir: false,
  plugins: [serverBundlePlugin(), virtualNoopPlugin],
  build: {
    // Rollup processes a no-op virtual module — all real work is in serverBundlePlugin
    rollupOptions: {
      input: 'virtual:noop',
      output: { format: 'cjs', inlineDynamicImports: true },
      onwarn(warning, warn) {
        // Suppress the expected "empty chunk" warning for the virtual no-op entry
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
