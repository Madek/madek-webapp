# Replace ampersand with TanStack Query + plain modules

## Context

The Madek2 webapp still depends on the legacy `ampersand-app`, `ampersand-model`, and `ampersand-rest-collection` libraries. With the Vite 8 and lodash-es migration complete, ampersand is the next legacy layer to remove.

Discovery shows the migration is smaller than it looks:
- Only **10 files import ampersand directly**; ~28 model files inherit from the shared bases.
- `ampersand-app` is used purely as a **static config singleton** for `APP_CONFIG` (from Rails). No session state.
- **React never subscribes to ampersand models** — no `model.on('change', …)` in any `.jsx`. Data flows to React via props from server-rendered bootstrap.
- The project has **no other state management library** (no Redux/Zustand/React Query/Context).

Because React and ampersand are decoupled, we replace a fetching/model layer that sits *beside* React, not one embedded in it. The goal: drop three legacy dependencies, get a modern server-state layer (TanStack Query) with caching / refetch / invalidation, and end up with plain JS modules instead of a bespoke class system.

## Approach

- **Data layer:** TanStack Query (`@tanstack/react-query`) for server state + plain `fetch` functions.
- **Language:** Stay in JS (matches current codebase).
- **Cadence:** Incremental, model-by-model. Ampersand and the new layer coexist until the last model is migrated.

## Target patterns

For each ampersand model, produce three artefacts:

1. **Fetcher** — plain async function in `app/javascript/api/`:
   ```js
   // app/javascript/api/media-entry.js
   export async function fetchMediaEntry(id) { … }
   export async function updateMediaEntry(id, patch) { … }
   ```
2. **Derived helpers** — plain functions replacing ampersand `derived`:
   ```js
   // app/javascript/lib/media-entry-helpers.js
   export const mediaType = (entry) => …
   export const isBatchEditable = (entry) => …
   ```
3. **Hook** — TanStack Query wrapper:
   ```js
   // app/javascript/hooks/use-media-entry.js
   export const useMediaEntry = (id) =>
     useQuery({ queryKey: ['media-entry', id], queryFn: () => fetchMediaEntry(id) })
   ```

Ampersand `session` state (e.g. `uploading` on `MediaEntry`) → local `useState`, or a small Zustand store later *only if* it turns out to be shared across components (defer that decision).

## Step-by-step plan

Each step is intended to ship as its own PR.

### Step 1 — Replace `ampersand-app` singleton
- Create `app/javascript/lib/app-config.js` exporting `{ config }` seeded from `window.APP_CONFIG`.
- Replace all `require('ampersand-app')` / `app.config` usages.
- Files to touch:
  - `app/javascript/application.js`
  - `app/javascript/embedded-view.js`
  - `app/javascript/models/media-entry.js`
  - `app/javascript/lib/current-locale.js`
  - any other `ampersand-app` importers
- Remove `ampersand-app` from `package.json`.

### Step 2 — Add TanStack Query
- Add `@tanstack/react-query`.
- Mount `QueryClientProvider` at the app root (`application.js` / `embedded-view.js`).
- Reasonable defaults: `staleTime` for reference data, disable retries where they'd double-post.

### Step 3 — Pilot: migrate the smallest model (User or ApiClient)
- Build fetcher + hook + helpers per the pattern above.
- Migrate the components that consume it.
- Keep the old ampersand model in parallel until callers are gone, then delete it.
- Establish conventions (file layout, error handling, query keys).

### Step 4 — Migrate `Permissions` collections
- `app/javascript/models/media-entry/permissions.js`
- `app/javascript/models/collection/permissions.js`
- Modelled as sub-queries or embedded in the parent query, whichever fits usage.

### Step 5 — Migrate `MediaEntry` and `Collection`
- Largest / most-used models. Do them after the pilot pattern is proven.
- Replace `derived` props with helper functions at call sites.

### Step 6 — Migrate remaining `MetaDatum` subtypes
- Text, TextDate, People, Keywords, Roles — cascading `.extend()` chain becomes a small `switch` or dispatch map on `type`.

### Step 7 — Retire ampersand
- Delete `app/javascript/models/shared/app-resource.js`, `app-collection.js`, `paginated-collection-factory.js`, and `models/index.js` if no longer referenced.
- Remove `ampersand-model` and `ampersand-rest-collection` from `package.json`.
- Run `npm dedupe` and confirm no transitive `ampersand-*` remain.

## Critical files

- `app/javascript/application.js` — app bootstrap, ampersand-app init
- `app/javascript/embedded-view.js` — second bootstrap entry
- `app/javascript/models/shared/app-resource.js` — base model class
- `app/javascript/models/shared/app-collection.js` — base collection class
- `app/javascript/models/shared/paginated-collection-factory.js` — pagination
- `app/javascript/models/media-entry.js` — largest model, migrate last of core set
- `app/javascript/models/index.js` — bulk model loader (candidate for deletion at the end)
- `package.json` — remove `ampersand-app`, `ampersand-model`, `ampersand-rest-collection`

## Reuse

- Existing `fetch`/HTTP conventions in the current ampersand `sync` overrides — port URL construction and header logic verbatim into the new fetchers rather than rewriting.
- `app/javascript/lib/current-locale.js` already reads `app.config` — use it as the first test case for the new `app-config.js` module.

## Verification per step

For each PR:
- `npm test` (spec suite green).
- Vite build succeeds (`npm run build`).
- Manually exercise the migrated model's flows in the browser:
  - list / detail view render
  - edit / update round-trip
  - permission checks still enforced (Step 4 onwards)
- After Step 7: `grep -r "ampersand" app/ package.json` returns nothing.

## Non-goals

- No TypeScript migration (explicitly deferred).
- No global client-state store (Zustand or otherwise) unless a concrete shared-session case appears.
- No React re-architecture beyond swapping the data source.
