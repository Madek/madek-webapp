# ESM-Only Migration Plan

**Date:** 2026-07-21
**Goal:** Enable Rollup, update Vite, make the project ESM-only, remove bespoke deps (starting with `active-lodash`).

## Guiding principles

- **Small, independently shippable steps.** Each phase leaves `master` green.
- **No behavioral changes.** Codemods and rewrites preserve semantics; if in doubt, prefer the safer replacement (e.g. keep `lodash-es/get`, don't invent a native equivalent).
- **Delete first, wrap second.** ESM wrappers around CJS deps are a fallback, not the goal.
- **One dep family per phase.** Don't mix `active-lodash` removal with `lodash` normalization in the same PR.

## Current state (baseline)

| Item | Value |
|------|-------|
| Files importing `active-lodash` | 55 |
| Files importing `lodash` / `lodash/*` | 57 |
| Files importing `global/window` | 1 (`app/javascript/models/media-entry.js`) |
| Build tool (client + server) | Vite (esbuild bypass path) |
| Rollup native build | Blocked (see `rollup-status.md`) |

## Phase 1 — Remove `active-lodash`

**Motivation:** Unmaintained personal wrapper, CJS-only, the primary Rollup blocker.

### 1a. Inventory ActiveSupport-only surface

`active-lodash` adds ~6 methods that aren't in plain lodash. Actual call counts:

| Method | Uses | Replacement |
|--------|------|-------------|
| `f.present(x)` | 39 | local helper `present(x)` |
| `f.presence(x)` | 9 | local helper `presence(x)` |
| `f.any(coll, fn)` | 8 | `some(coll, fn)` from lodash-es |
| `f.include(coll, v)` | 7 | `includes(coll, v)` |
| `f.object(pairs)` | 5 | `Object.fromEntries(pairs)` |
| `f.trimLeft(s)` | 1 | `s.trimStart()` |

Create `app/javascript/lib/present.js`:

```javascript
// present: true if value has meaningful content (Rails-style)
// - null/undefined → false
// - '' or whitespace-only → false
// - [] / {} → false
// - everything else → true
export function present(x) {
  if (x == null) return false
  if (typeof x === 'string') return x.trim().length > 0
  if (Array.isArray(x)) return x.length > 0
  if (typeof x === 'object') return Object.keys(x).length > 0
  return true
}
export const presence = (x) => (present(x) ? x : null)
```

Cross-check against `active-lodash` source before merging — the exact ActiveSupport semantics for numbers/booleans/dates matter.

### 1b. Codemod: `active-lodash` → `lodash-es`

Add `lodash-es` to dependencies (keep `lodash` for now, remove in Phase 2).

Rewrite rules, applied file-by-file with a jscodeshift or scripted regex pass:

| Before | After |
|--------|-------|
| `import f from 'active-lodash'` | `import * as f from 'lodash-es'` + `import { present, presence } from '.../lib/present'` (when used) |
| `import { X, Y } from 'active-lodash'` | `import { X, Y } from 'lodash-es'` |
| `f.present(x)` | `present(x)` |
| `f.presence(x)` | `presence(x)` |
| `f.any(...)` | `f.some(...)` |
| `f.include(...)` | `f.includes(...)` |
| `f.object(pairs)` | `Object.fromEntries(pairs)` |
| `f.trimLeft(s)` | `s.trimStart()` |

**Decision (locked):** use named imports. `import { map, get, filter } from 'lodash-es'` and rewrite `f.map(...)` → `map(...)` at call sites. Tree-shakes cleanly and is the ESM idiom.

### 1c. Remove `active-lodash` from `package.json`

Verify with `grep -r "active-lodash" app/` returns nothing. Delete the dep, `npm install`, rerun full build.

**Effort:** ~1 day for the codemod (including manual review of the 55 files) + half a day for helper validation and testing.

## Phase 2 — Normalize `lodash` → `lodash-es`

**Motivation:** ESM-only goal; also removes the second lodash flavor.

- 57 files import `lodash` or `lodash/*` sub-paths.
- Sub-path imports (`lodash/get` → `lodash-es/get`) map 1:1.
- `import _ from 'lodash'` → `import * as _ from 'lodash-es'` OR named imports (same decision as Phase 1).

Remove `lodash` from `package.json`. Verify no transitive dep still pulls it via `npm ls lodash`.

**Effort:** ~half a day (mechanical).

## Phase 3 — Remove `global/window`

Only one file: `app/javascript/models/media-entry.js`. `File` is a browser global — no import needed. Replace `import { File as BrowserFile } from 'global/window'` with direct use of `File` (or `globalThis.File` if lint complains).

Remove `global` from `package.json`. Note: `globals` (plural, different package) may still be needed — check ESLint config.

**Effort:** 15 minutes.

## Phase 4 — Retry Rollup

With the two documented blockers gone:

1. Run the Rollup config from the experimental branch.
2. If new CJS-only deps surface, triage each: replace, wrap, or `@rollup/plugin-commonjs` include list.
3. Compare bundle sizes esbuild vs. Rollup — capture numbers so the decision is evidence-based.

Likely remaining suspects (based on `package.json` age): `ampersand-*`, `babyparse`, `hashblot`, `history@2.1.2`, `bulk-require`, `xhr`, `async@2.x`. Each is a small, isolated investigation.

**Effort:** 1–2 days depending on how many new blockers surface.

## Phase 5 — Update Vite

Only after Phase 4 is stable. Bumping Vite while Rollup interop is unresolved conflates failures.

Steps:
1. `npm outdated vite @vitejs/plugin-react`
2. Read the changelog for breaking changes between our version and latest.
3. Bump, run both `vite.config.client.mjs` and `vite.config.server.mjs` builds.
4. Verify dev server, watch mode, and production build.

**Effort:** unknown — depends on version delta and plugin API changes.

## Phase 6 — `"type": "module"` in `package.json`

The final ESM-only step. Blocks: any remaining `.js` files that use `require()` or `module.exports` must be either renamed to `.cjs` or converted. The `expand-bulk-require.mjs` interop shim documented in `rollup-status.md` will need re-evaluation.

Do this last; it forces the whole graph to be ESM-clean.

## Out of scope (for now)

- Replacing `lodash-es` with native. Many uses (`get` with path strings, `merge` deep, `cloneDeep`, `curry`) don't have clean native equivalents. Not worth the risk.
- Replacing `ampersand-*`. Larger project, unrelated to build modernization.
- React 16 → 18. Separate track.

## Decisions (locked in)

1. **Call-site style**: named imports (`import { map } from 'lodash-es'`, rewrite `f.map(...)` → `map(...)`).
2. **`present`/`presence` semantics**: mirror `active-lodash`'s exact behavior. Before writing the helper, read `node_modules/active-lodash/src/` and grep the 48 call sites in-tree to confirm no edge case relies on undocumented behavior. Add unit tests for the helper.
3. **Codemod tooling**: jscodeshift. AST-aware handling is essential for the named-import rewrite — collision detection (what if a file already imports something named `map`?) and preserving comments/formatting are hard with regex.

## Rough total effort

~3–5 days of focused work through Phase 4. Phases 5–6 are open-ended.
