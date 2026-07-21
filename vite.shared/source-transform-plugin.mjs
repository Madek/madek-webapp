/**
 * source-transform-plugin.mjs
 *
 * esbuild plugin that applies source transforms for .js/.jsx files:
 *   1. brfs:         inline require('fs').readFileSync(...) calls at build time
 *   2. bulkify:      expand requireBulk(__dirname, [...]) calls
 *   3. mixedEsmCjs:  convert mixed ESM+CJS files to pure CJS so that
 *                    module.exports semantics are preserved (decaffeinate pattern)
 *   4. shorthand-properties: convert object literal method shorthands to regular
 *                    function expressions so they are constructable with `new`
 */

import { dirname, join } from 'path'
import { readFileSync, promises as fsp } from 'fs'
import { transform as esbuildTransform } from 'esbuild'
import { createRequire } from 'module'
import { expandBulkRequire } from './expand-bulk-require.mjs'

const _require = createRequire(import.meta.url)

// Lazily resolve Babel so it is only loaded when needed
function getBabel() {
  return _require('@babel/core')
}

export const sourceTransformPlugin = {
  name: 'source-transform',
  setup(build) {
    build.onLoad({ filter: /\.(jsx?)$/ }, async args => {
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
        if (bulked !== code) {
          code = bulked
          changed = true
        }
      }

      // ── 3. mixedEsmCjs: convert mixed ESM+CJS to pure CJS ────────────────
      // Some files use both `export default X` and `module.exports = X`
      // (a pattern left by decaffeinate). esbuild in ESM mode ignores
      // module.exports; we must convert to CJS first so module.exports wins.
      //
      // Skip node_modules: third-party ESM packages (e.g. lodash-es) reference
      // `module.exports` inside CJS feature-detection blocks — never as an
      // actual export — but a naive string match would corrupt them.
      const isNodeModule = args.path.includes('/node_modules/')
      const hasCjsExports = !isNodeModule && /\bmodule\.exports\b/.test(code)
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
      // Convert object literal method shorthands to regular function expressions
      // so they are constructable with `new`. Ampersand collections call
      // `new this.model(attrs)`, so the `model` property must be a regular
      // function expression. Babel's shorthand-properties plugin converts
      // `{ foo(a) {} }` → `{ foo: function foo(a) {} }` without touching
      // any other modern syntax.
      if (!args.path.includes('/node_modules/')) {
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

      // Return as plain JS — JSX has been compiled away
      return { contents: code, loader: 'js' }
    })
  }
}
