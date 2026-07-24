/**
 * source-transform-plugin.mjs
 *
 * Rolldown/Rollup/Vite plugin that applies source transforms for .js/.jsx files:
 *   1. brfs:    inline require('fs').readFileSync(...) calls at build time
 *   2. bulkify: expand requireBulk(__dirname, [...]) calls into static requires
 *   3. babel:   JSX transform + shorthand-properties (constructable with `new`)
 *
 * Note: the previous mixedEsmCjs step (esbuild-based CJS conversion) is no longer
 * needed — Rolldown handles CJS/ESM interop natively.
 */

import { dirname, join } from 'path'
import { readFileSync } from 'fs'
import { createRequire } from 'module'
import { expandBulkRequire } from './expand-bulk-require.mjs'

const _require = createRequire(import.meta.url)

function getBabel() {
  return _require('@babel/core')
}

export function sourceTransformPlugin(isDev = false) {
  const nodeEnv = isDev ? 'development' : 'production'

  return {
    name: 'source-transform',

    async transform(code, id) {
      if (!/\.(jsx?)$/.test(id)) return null

      const fileDir = dirname(id)
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
          code = code.replace(/\bvar\s+path\s*=\s*require\(['"]path['"]\);?\s*\n?/g, '')
        }
      }

      // ── 2. bulkify: expand requireBulk(__dirname, [...]) ─────────────────
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

      // ── 3. process.env.NODE_ENV replacement ──────────────────────────────
      if (code.includes('process.env.NODE_ENV')) {
        code = code.replace(/process\.env\.NODE_ENV/g, JSON.stringify(nodeEnv))
        changed = true
      }

      // ── 4. Babel: JSX + shorthand-properties (skip node_modules) ─────────
      if (!id.includes('/node_modules/')) {
        const babel = getBabel()
        const babelResult = babel.transformSync(code, {
          filename: id,
          configFile: false,
          babelrc: false,
          plugins: ['@babel/plugin-transform-shorthand-properties'],
          presets: [
            [
              '@babel/preset-react',
              { pragma: 'React.createElement', pragmaFrag: 'React.Fragment' }
            ]
          ]
        })
        if (babelResult && babelResult.code !== code) {
          code = babelResult.code
          changed = true
        }
      }

      if (!changed) return null
      return { code, map: null }
    }
  }
}
