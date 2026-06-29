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
// esbuild plugin: fix non-standard '...' paths that browserify's 'resolve'
// module handles but esbuild's standard path resolution rejects.
// ---------------------------------------------------------------------------
const tripleDotsResolvePlugin = {
  name: 'triple-dots-resolve',
  setup(build) {
    // Intercept any import path that contains '...' (triple dot)
    build.onResolve({ filter: /\.\.\./ }, (args) => {
      return new Promise((resolvePromise) => {
        resolveModule(
          args.path,
          { basedir: args.resolveDir || dirname(args.importer) },
          (err, resolved) => {
            if (err) {
              resolvePromise({ errors: [{ text: err.message }] })
            } else {
              resolvePromise({ path: resolved })
            }
          }
        )
      })
    })
  },
}

// ---------------------------------------------------------------------------
// Helper: expand a bulk-require call into a nested object of require() calls
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
// esbuild plugin: combined source transform for .js/.jsx files.
//
// Applies transforms in order within one onLoad handler so they can chain:
//   1. brfs:         inline require('fs').readFileSync(...) calls at build time
//   2. bulkify:      expand requireBulk(__dirname, [...]) calls
//   3. mixedEsmCjs:  convert mixed ESM+CJS files to pure CJS so that
//                    module.exports semantics are preserved (decaffeinate pattern)
// ---------------------------------------------------------------------------
const sourceTransformPlugin = {
  name: 'source-transform',
  setup(build) {
    build.onLoad({ filter: /\.(jsx?)$/ }, async (args) => {
      let code = await fsp.readFile(args.path, 'utf8')
      const fileDir = dirname(args.path)
      let changed = false

      // ── 1. brfs: inline fs.readFileSync(..., 'utf8') ─────────────────────
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
          // Remove the now-unused `var path = require('path')` declaration that
          // was only needed as an argument to the inlined readFileSync call.
          code = code.replace(/\bvar\s+path\s*=\s*require\(['"]path['"]\);?\s*\n?/g, '')
        }
      }

      // ── 2. bulkify: expand requireBulk(__dirname, [...]) ─────────────────
      if (code.includes('bulk-require')) {
        let bulked = code

        // Expand call sites
        const callRegex = /requireBulk\s*\(\s*__dirname\s*,\s*(\[[\s\S]*?\])\s*\)/g
        bulked = bulked.replace(callRegex, (_match, patternsStr) => {
          const patterns = Array.from(patternsStr.matchAll(/['"]([^'"]+)['"]/g), m => m[1])
          return expandBulkRequire(fileDir, patterns)
        })
        // Remove the now-unused import/require declaration
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

      // ── 3. mixedEsmCjs: convert mixed ESM+CJS to pure CJS ────────────────
      // Some files use both `export default X` and `module.exports = X`
      // (a pattern left by decaffeinate). esbuild in ESM mode ignores
      // module.exports; we must convert to CJS first so module.exports wins.
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

      // Return as plain JS — JSX has been compiled away
      return { contents: code, loader: 'js' }
    })
  },
}

// ---------------------------------------------------------------------------
// Vite plugin: runs the esbuild bundle as part of `vite build`
// Supports:
//   - production build  → bundle-react-server-side-vite.js
//   - dev one-shot build (NODE_ENV=development) → dev-bundle-react-server-side-vite.js
//   - watch mode (--watch)  → dev-bundle-react-server-side-vite.js + source maps
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
      const isDev = isWatch || process.env.NODE_ENV === 'development'
      const outfile = resolve(
        __dirname,
        isDev
          ? 'public/assets/bundles/dev-bundle-react-server-side-vite.js'
          : 'public/assets/bundles/bundle-react-server-side-vite.js'
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
        // crypto is explicitly ignored by the existing browserify build.
        // fs and net have no browser shim in esbuild; they are handled by the
        // require stub in the banner above.
        external: ['crypto', 'fs', 'net'],
        plugins: [tripleDotsResolvePlugin, sourceTransformPlugin],
        sourcemap: isDev,
        minify: false,
      }

      if (isWatch) {
        if (esbuildCtx) return  // already watching
        console.log('\nWatching server-side bundle with esbuild…')
        esbuildCtx = await esbuildContext(esbuildOptions)
        await esbuildCtx.watch()
        console.log('  →', outfile.replace(__dirname + '/', ''))
      } else {
        console.log('\nBuilding server-side bundle with esbuild…')
        await esbuildBuild(esbuildOptions)
        console.log('  →', outfile.replace(__dirname + '/', ''))
      }
    },
  }
}

// ---------------------------------------------------------------------------
// Vite config — minimal, just a vehicle to run the esbuild bundle plugin
// ---------------------------------------------------------------------------
export default defineConfig({
  publicDir: false,
  plugins: [
    serverBundlePlugin(),
    // Virtual module so Rollup has a valid (empty) entry to process
    {
      name: 'virtual-noop',
      resolveId(id) { if (id === 'virtual:noop') return id },
      load(id) { if (id === 'virtual:noop') return 'export default {}' },
    },
  ],
  build: {
    // Rollup processes a no-op virtual module — all real work is in serverBundlePlugin
    rollupOptions: {
      input: 'virtual:noop',
      output: { format: 'cjs', inlineDynamicImports: true },
      onwarn(warning, warn) {
        // Suppress the expected "empty chunk" warning for the virtual no-op entry
        if (warning.code === 'EMPTY_BUNDLE') return
        warn(warning)
      },
    },
    outDir: '/tmp/vite-server-noop',
    emptyOutDir: true,
    minify: false,
    write: false,
  },
})
