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
import { build as esbuildBuild, transform as esbuildTransform } from 'esbuild'
import { resolve, dirname, basename, extname, join } from 'path'
import { readFileSync, promises as fsp } from 'fs'
import { fileURLToPath } from 'url'
import fg from 'fast-glob'
import resolveModule from 'resolve'

const { sync: globSync } = fg

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// ---------------------------------------------------------------------------
// esbuild plugin: convert mixed ESM+CJS files to pure CJS.
//
// Some source files use both ESM exports (`export default X`) and CJS exports
// (`module.exports = X`) — a pattern left by decaffeinate migrations.  In
// browserify+babelify these work because babelify converts ESM→CJS first, then
// `module.exports = X` wins.  esbuild (strict ESM mode) ignores module.exports
// for files with ESM syntax.  This plugin pre-converts such files to CJS so
// that the CJS semantics are preserved.
// ---------------------------------------------------------------------------
const mixedEsmCjsPlugin = {
  name: 'mixed-esm-cjs',
  setup(build) {
    build.onLoad({ filter: /\.(jsx?)$/ }, async (args) => {
      const code = await fsp.readFile(args.path, 'utf8')

      // Only act on files that mix CJS (module.exports) with ESM (import/export)
      const hasCjsExports = /\bmodule\.exports\b/.test(code)
      const hasEsmSyntax = /(?:^|\n)\s*(?:import\s|export\s)/.test(code)
      if (!hasCjsExports || !hasEsmSyntax) return undefined

      // Use esbuild's transform to convert ESM→CJS (no bundling, just syntax)
      const ext = args.path.endsWith('.jsx') ? 'jsx' : 'js'
      const result = await esbuildTransform(code, {
        loader: ext,
        format: 'cjs',
        jsx: 'transform',
        jsxFactory: 'React.createElement',
        jsxFragment: 'React.Fragment',
        target: 'es2015',
      })

      return { contents: result.code, loader: 'js' }
    })
  },
}

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
const brfsEsbuildPlugin = {
  name: 'brfs',
  setup(build) {
    build.onLoad({ filter: /\.js$/ }, async (args) => {
      const code = await fsp.readFile(args.path, 'utf8')
      if (!code.includes('readFileSync')) return undefined

      const fileDir = dirname(args.path)

      const regex =
        /require\(['"]fs['"]\)\.readFileSync\(\s*(?:require\(['"]path['"]\)\.join|path\.join)\s*\(\s*__dirname\s*,\s*(['"][^'"]+['"])\s*\)\s*,\s*['"]utf8['"]\s*\)/gs

      const newCode = code.replace(regex, (_match, relPathStr) => {
        const relPath = relPathStr.replace(/^['"]|['"]$/g, '')
        const absolutePath = join(fileDir, relPath)
        return JSON.stringify(readFileSync(absolutePath, 'utf8'))
      })

      if (newCode === code) return undefined
      return { contents: newCode, loader: 'js' }
    })
  },
}

// ---------------------------------------------------------------------------
// esbuild plugin: bulkify — expand requireBulk(__dirname, [...]) calls
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

const bulkifyEsbuildPlugin = {
  name: 'bulkify',
  setup(build) {
    // Match any .js or .jsx file that imports bulk-require
    build.onLoad({ filter: /\.(jsx?)$/ }, async (args) => {
      const code = await fsp.readFile(args.path, 'utf8')
      if (!code.includes('bulk-require')) return undefined

      const fileDir = dirname(args.path)
      let newCode = code

      // 1. Expand requireBulk(__dirname, [...]) call sites
      const callRegex = /requireBulk\s*\(\s*__dirname\s*,\s*(\[[\s\S]*?\])\s*\)/g
      newCode = newCode.replace(callRegex, (_match, patternsStr) => {
        const patterns = Array.from(patternsStr.matchAll(/['"]([^'"]+)['"]/g), m => m[1])
        return expandBulkRequire(fileDir, patterns)
      })

      // 2. Remove the now-unused import/require declaration
      newCode = newCode.replace(
        /(?:const|var|let)\s+requireBulk\s*=\s*require\(['"]bulk-require['"]\)\s*\n?/g,
        '// (bulk-require import removed by bulkify esbuild plugin)\n'
      )
      newCode = newCode.replace(
        /import\s+requireBulk\s+from\s+['"]bulk-require['"]\s*\n?/g,
        '// (bulk-require import removed by bulkify esbuild plugin)\n'
      )

      if (newCode === code) return undefined

      // Determine the loader from the file extension
      const loader = args.path.endsWith('.jsx') ? 'jsx' : 'js'
      return { contents: newCode, loader }
    })
  },
}

// ---------------------------------------------------------------------------
// Vite plugin: runs the esbuild bundle as part of `vite build`
// ---------------------------------------------------------------------------
function serverBundlePlugin() {
  return {
    name: 'server-bundle',
    apply: 'build',

    // Run AFTER Vite has finished its own (no-op) build
    async closeBundle() {
      console.log('\nBuilding server-side bundle with esbuild…')

      await esbuildBuild({
        entryPoints: [resolve(__dirname, 'app/javascript/react-server-side.js')],
        bundle: true,
        platform: 'node',
        format: 'cjs',
        outfile: resolve(__dirname, 'public/assets/bundles/bundle-react-server-side-vite.js'),
        // Treat .js files as JSX (some source files use JSX with a .js extension)
        loader: { '.js': 'jsx', '.jsx': 'jsx' },
        // Use the classic React.createElement pragma (React 16, matches browserify build)
        jsxFactory: 'React.createElement',
        jsxFragment: 'React.Fragment',
        define: { 'process.env.NODE_ENV': '"production"' },
        // Ignore the `crypto` module (not used, browserify also ignores it)
        external: ['crypto'],
        // Custom transforms: brfs (inline readFileSync) and bulkify (expand requireBulk)
        plugins: [tripleDotsResolvePlugin, mixedEsmCjsPlugin, brfsEsbuildPlugin, bulkifyEsbuildPlugin],
        // Single-file output, no source maps needed for the server bundle
        sourcemap: false,
        minify: false,
      })

      console.log('  → public/assets/bundles/bundle-react-server-side-vite.js')
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
    },
    outDir: 'public/assets/bundles',
    emptyOutDir: false,
    minify: false,
    write: false, // don't write Rollup's (empty) output — esbuild writes the real file
  },
})
