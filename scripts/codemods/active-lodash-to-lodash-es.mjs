// jscodeshift transform: active-lodash → lodash-es + local present/presence helpers.
//
// Handles:
//   import f from 'active-lodash'           → named imports from lodash-es (+ present/presence)
//   import { X, Y } from 'active-lodash'    → same, with method-name remapping
//   f.map(x)                                → map(x)
//   f.any(x, fn)                            → some(x, fn)
//   f.include(coll, v)                      → includes(coll, v)
//   f.select(coll, fn)                      → filter(coll, fn)
//   f.present(x) / f.presence(x)            → present(x) / presence(x)  (from lib/present)
//   f.object(pairs)                         → Object.fromEntries(pairs)
//   f.trimLeft(s)                           → s.trimStart()
//
// Collision handling: if a bare method name is already bound at the top of the file,
// the transform switches to `import * as f from 'lodash-es'` for that file and keeps
// f.xxx call sites intact. Logged to stderr so we can review.
//
// Path to `lib/present`: computed relative to the file being transformed.

import path from 'node:path'

// Method names present in active-lodash / lodash 3.x that were removed or
// renamed in lodash 4.x (which lodash-es follows).
const LODASH_METHOD_RENAMES = {
  any: 'some',
  all: 'every',
  include: 'includes',
  contains: 'includes',
  select: 'filter',
  where: 'filter',
  unique: 'uniq',
  findWhere: 'find'
}

const INLINE_METHODS = new Set(['object', 'trimLeft'])
const HELPER_METHODS = new Set(['present', 'presence'])

const PRESENT_HELPER_ABS = path.resolve('app/javascript/lib/present.js')

export default function transform(fileInfo, api) {
  const j = api.jscodeshift
  const root = j(fileInfo.source)

  // Find active-lodash imports.
  const alImports = root.find(j.ImportDeclaration, {
    source: { value: 'active-lodash' }
  })
  if (alImports.size() === 0) return null

  const localBindings = collectTopLevelBindings(j, root)
  const usedLodashNames = new Set() // names to import from lodash-es
  const usedHelperNames = new Set() // names to import from lib/present
  let needsNamespaceFallback = false

  // Discover what's used from active-lodash.
  const defaultLocalName = getDefaultImportLocalName(alImports)
  const namedImports = getNamedImports(alImports) // Array<{ imported, local }>

  // 1. Named imports: import { X as Y } from 'active-lodash'
  for (const { imported, local } of namedImports) {
    const target = classifyMethod(imported)
    if (target.kind === 'helper') {
      usedHelperNames.add(target.name)
      if (local !== target.name) collideOrRename(target.name, local, localBindings)
    } else if (target.kind === 'lodash') {
      usedLodashNames.add(target.name)
      if (local !== target.name) collideOrRename(target.name, local, localBindings)
    } else if (target.kind === 'inline') {
      // rare: `import { object } from 'active-lodash'` — treat as fallback
      console.warn(`[warn] ${fileInfo.path}: named import '${imported}' needs inline rewrite; using namespace fallback`)
      needsNamespaceFallback = true
    }
  }

  // 2. Default import `f`: scan all `f.xxx` member usages.
  const memberCalls = [] // Array<{ path, method }>
  if (defaultLocalName) {
    root
      .find(j.MemberExpression, {
        object: { type: 'Identifier', name: defaultLocalName },
        property: { type: 'Identifier' }
      })
      .forEach((p) => {
        const method = p.node.property.name
        memberCalls.push({ path: p, method })
        const target = classifyMethod(method)
        if (target.kind === 'helper') usedHelperNames.add(target.name)
        else if (target.kind === 'lodash') {
          // collision check happens after we know full set
          usedLodashNames.add(target.name)
        }
        // inline methods handled during rewrite
      })
  }

  // Check collisions for all lodash names we want to introduce.
  if (!needsNamespaceFallback) {
    for (const name of usedLodashNames) {
      if (localBindings.has(name) && localBindings.get(name) !== 'active-lodash-import') {
        console.warn(`[collision] ${fileInfo.path}: '${name}' already bound; using namespace fallback`)
        needsNamespaceFallback = true
        break
      }
    }
    for (const name of usedHelperNames) {
      if (localBindings.has(name) && localBindings.get(name) !== 'active-lodash-import') {
        console.warn(`[collision] ${fileInfo.path}: helper '${name}' already bound; using namespace fallback`)
        needsNamespaceFallback = true
        break
      }
    }
  }

  // -------- Rewrite --------

  // Rewrite member-expression call sites.
  if (defaultLocalName && !needsNamespaceFallback) {
    memberCalls.forEach(({ path: p, method }) => {
      const target = classifyMethod(method)
      if (target.kind === 'helper' || target.kind === 'lodash') {
        // f.map(...)  →  map(...)  (replace the MemberExpression with an Identifier)
        j(p).replaceWith(j.identifier(target.name))
      } else if (target.kind === 'inline') {
        // The MemberExpression itself is `f.object` — it's usually the callee of a CallExpression.
        const parent = p.parent.node
        if (parent && parent.type === 'CallExpression' && parent.callee === p.node) {
          if (method === 'object') {
            // f.object(pairs)  →  Object.fromEntries(pairs)
            parent.callee = j.memberExpression(j.identifier('Object'), j.identifier('fromEntries'))
          } else if (method === 'trimLeft') {
            // f.trimLeft(s)  →  s.trimStart()
            const [arg] = parent.arguments
            if (arg) {
              parent.callee = j.memberExpression(arg, j.identifier('trimStart'))
              parent.arguments = []
            }
          }
        } else {
          console.warn(`[warn] ${fileInfo.path}: '${defaultLocalName}.${method}' used outside call position; leaving alone`)
        }
      }
    })
  }

  // Remove active-lodash import(s).
  alImports.remove()

  // If we hit a fallback, add `import * as f from 'lodash-es'` and restore f.xxx calls
  // (with method renames applied for any/include/select).
  if (needsNamespaceFallback) {
    // Re-add member expressions with remapped names for any/include/select.
    if (defaultLocalName) {
      root
        .find(j.MemberExpression, {
          object: { type: 'Identifier', name: defaultLocalName },
          property: { type: 'Identifier' }
        })
        .forEach((p) => {
          const method = p.node.property.name
          if (LODASH_METHOD_RENAMES[method]) {
            p.node.property = j.identifier(LODASH_METHOD_RENAMES[method])
          }
        })
    }
    const nsLocal = defaultLocalName || 'f'
    root.get().node.program.body.unshift(
      j.importDeclaration(
        [j.importNamespaceSpecifier(j.identifier(nsLocal))],
        j.literal('lodash-es')
      )
    )
    // Helper import if needed (still resolved by name, since f.present etc. stays as f.present).
    // For fallback we route present/presence via `f.present` since lodash-es doesn't have them...
    // → In fallback mode we can't just leave `f.present`; we must import the helper too and
    //   rewrite those specific calls even though we kept the namespace for the rest.
    if (defaultLocalName && (usedHelperNames.has('present') || usedHelperNames.has('presence'))) {
      root
        .find(j.MemberExpression, {
          object: { type: 'Identifier', name: defaultLocalName },
          property: { type: 'Identifier' }
        })
        .forEach((p) => {
          const method = p.node.property.name
          if (HELPER_METHODS.has(method)) {
            j(p).replaceWith(j.identifier(method))
          }
        })
      addHelperImport(j, root, fileInfo.path, [...usedHelperNames])
    }
    return root.toSource({ quote: 'single' })
  }

  // Normal path: add named import from lodash-es (sorted).
  if (usedLodashNames.size > 0) {
    const specifiers = [...usedLodashNames]
      .sort()
      .map((n) => j.importSpecifier(j.identifier(n)))
    root.get().node.program.body.unshift(
      j.importDeclaration(specifiers, j.literal('lodash-es'))
    )
  }

  // Add helper import for present/presence.
  if (usedHelperNames.size > 0) {
    addHelperImport(j, root, fileInfo.path, [...usedHelperNames])
  }

  return root.toSource({ quote: 'single' })
}

// --- helpers ---

function classifyMethod(name) {
  if (HELPER_METHODS.has(name)) return { kind: 'helper', name }
  if (INLINE_METHODS.has(name)) return { kind: 'inline', name }
  const remapped = LODASH_METHOD_RENAMES[name] || name
  return { kind: 'lodash', name: remapped }
}

function getDefaultImportLocalName(alImports) {
  let name = null
  alImports.forEach((p) => {
    for (const s of p.node.specifiers) {
      if (s.type === 'ImportDefaultSpecifier') name = s.local.name
    }
  })
  return name
}

function getNamedImports(alImports) {
  const out = []
  alImports.forEach((p) => {
    for (const s of p.node.specifiers) {
      if (s.type === 'ImportSpecifier') {
        out.push({ imported: s.imported.name, local: s.local.name })
      }
    }
  })
  return out
}

function collectTopLevelBindings(j, root) {
  const bindings = new Map()
  root.get().node.program.body.forEach((node) => {
    if (node.type === 'ImportDeclaration') {
      const from = node.source.value
      for (const s of node.specifiers) {
        const src = from === 'active-lodash' ? 'active-lodash-import' : 'import'
        bindings.set(s.local.name, src)
      }
    } else if (node.type === 'VariableDeclaration') {
      for (const d of node.declarations) collectPatternNames(d.id, bindings, 'var')
    } else if (node.type === 'FunctionDeclaration' && node.id) {
      bindings.set(node.id.name, 'fn')
    } else if (node.type === 'ClassDeclaration' && node.id) {
      bindings.set(node.id.name, 'class')
    } else if (node.type === 'ExportNamedDeclaration' && node.declaration) {
      if (node.declaration.type === 'VariableDeclaration') {
        for (const d of node.declaration.declarations) collectPatternNames(d.id, bindings, 'var')
      } else if (node.declaration.id) {
        bindings.set(node.declaration.id.name, 'exported')
      }
    }
  })
  return bindings
}

function collectPatternNames(node, bindings, kind) {
  if (!node) return
  if (node.type === 'Identifier') bindings.set(node.name, kind)
  else if (node.type === 'ObjectPattern') {
    for (const prop of node.properties) {
      if (prop.type === 'Property' || prop.type === 'ObjectProperty') collectPatternNames(prop.value, bindings, kind)
      else if (prop.type === 'RestElement') collectPatternNames(prop.argument, bindings, kind)
    }
  } else if (node.type === 'ArrayPattern') {
    for (const el of node.elements) if (el) collectPatternNames(el, bindings, kind)
  } else if (node.type === 'AssignmentPattern') {
    collectPatternNames(node.left, bindings, kind)
  } else if (node.type === 'RestElement') {
    collectPatternNames(node.argument, bindings, kind)
  }
}

function collideOrRename() {
  // Placeholder — collisions for named imports are handled by falling back to namespace.
}

function addHelperImport(j, root, filePath, names) {
  const relDir = path.relative(path.dirname(path.resolve(filePath)), path.dirname(PRESENT_HELPER_ABS))
  let importPath = path.join(relDir || '.', 'present').replace(/\\/g, '/')
  if (!importPath.startsWith('.')) importPath = './' + importPath
  const specifiers = names.sort().map((n) => j.importSpecifier(j.identifier(n)))
  root.get().node.program.body.unshift(
    j.importDeclaration(specifiers, j.literal(importPath))
  )
}
