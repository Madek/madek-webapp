# TODO: Checksum Implementation for Media Files

## Overview
Add checksum generation and verification for original media files, displayed in the Export dialog ("Medieneintrag exportieren").

**Algorithm**: MD5  
**Scope**: Original source files only (not previews)

---

## Step 1: Database Migration

**File**: `datalayer/db/migrate/074_add_checksum_to_media_files.rb`

Add 2 columns to `media_files` table:

| Column | Type | Default | Purpose |
|---|---|---|---|
| `checksum` | `string` | `NULL` | Stored MD5 reference hash |
| `checksum_verified_at` | `timestamptz` | `NULL` | Last verification timestamp |

State logic:
- `checksum` NULL → not generated (State A)
- `checksum` set, `checksum_verified_at` NULL → generated, not verified (State B)
- `checksum` set, `checksum_verified_at` set → verified (State C)

After migration, regenerate `datalayer/db/structure.sql`.

---

## Step 2: Model — `MediaFile`

**File**: `datalayer/app/models/media_file.rb`

Uncomment `require 'digest'` at line 1.

Add two public methods:

### `generate_checksum!`
1. Read file from `original_store_location`
2. Compute `Digest::MD5.hexdigest(File.read(path))`
3. Update columns: `checksum`, reset `checksum_verified_at = NULL`

### `verify_checksum!`
1. Read file from `original_store_location`
2. Recompute MD5 hash
3. Compare with stored `checksum`
4. Update: `checksum_verified_at = Time.current`
5. Return match result (`true` / `false`) — displayed transiently in frontend
6. **Never** modify the stored `checksum` value

---

## Step 3: Routes + Controller

### Routes
**File**: `config/routes.rb` — inside `media_entries` member block (near line 68):

```ruby
post 'checksum/generate', action: :generate_checksum
post 'checksum/verify', action: :verify_checksum
```

### Controller Concern
**File**: `app/controllers/modules/media_entries/checksum.rb` (new)

Two actions:
- `generate_checksum` — authorize, call `media_file.generate_checksum!`, respond JSON
- `verify_checksum` — authorize, call `media_file.verify_checksum!`, respond JSON

JSON response shape (generate):
```json
{
  "checksum": "290aa235d298df92987a975"
}
```

JSON response shape (verify):
```json
{
  "checksum": "290aa235d298df92987a975",
  "checksum_verified_at": "2025-05-02T...",
  "match": true
}
```

### Include in Controller
**File**: `app/controllers/media_entries_controller.rb`

```ruby
include Modules::MediaEntries::Checksum
```

---

## Step 4: Presenter

### MediaFile Presenter
**File**: `app/presenters/presenters/media_files/media_file.rb`

Add delegated fields:
```ruby
delegate_to_app_resource :checksum, :checksum_verified_at
```

### MediaEntryShow Presenter
**File**: `app/presenters/presenters/media_entries/media_entry_show.rb`

Add method returning checksum action URLs:
```ruby
def checksum_urls
  {
    generate: generate_checksum_media_entry_path(@app_resource),
    verify: verify_checksum_media_entry_path(@app_resource)
  }
end
```

---

## Step 5: Frontend — Export Dialog

**File**: `app/javascript/react/views/MediaEntry/Export.jsx`

Add a **Prüfsumme** section between the Original section and the Bilder/previews section.

### Three UI States

**State A — No checksum** (`checksum` is null):
```
Prüfsumme
Prüfsumme erzeugen                       [Erzeugen]
```

**State B — Checksum exists, not yet verified** (`checksum` set, `checksum_verified_at` null):
```
Prüfsumme
290aa235d298df92987a975                   [Prüfen]
```

**State C — Checksum exists and verified** (`checksum_verified_at` set):
```
Prüfsumme
290aa235d298df92987a975   2.5.2025        [erneut Prüfen]
```

### Implementation Notes
- Use local React `state` to track checksum data after async POST calls
- POST to generate/verify endpoints using `fetch` with CSRF token
- Update displayed data without full page reload
- Show loading indicator while request is in-flight
- Verify response `match` field: show transient OK/FAIL feedback

---

## Step 6: Translations

**File**: `config/locale/translations.csv`

| Key | DE | EN |
|---|---|---|
| `media_entry_export_checksum` | Prüfsumme | Checksum |
| `media_entry_export_checksum_generate` | Prüfsumme erzeugen | Generate checksum |
| `media_entry_export_checksum_generate_btn` | Erzeugen | Generate |
| `media_entry_export_checksum_verify_btn` | Prüfen | Verify |
| `media_entry_export_checksum_reverify_btn` | erneut Prüfen | Re-verify |
| `media_entry_export_checksum_match_ok` | OK | OK |
| `media_entry_export_checksum_match_fail` | FEHLGESCHLAGEN | FAIL |

---

## Execution Order

```
Step 1  Migration
  |
  v
Step 2  Model methods
  |
  v
Step 3  Routes + Controller concern
  |
  v
Step 4  Presenter (expose data to frontend)
  |
  v
Step 5  Frontend (Export.jsx)

Step 6  Translations (parallel with Steps 2-5)
```

---

## Key Files Summary

| Layer | File |
|---|---|
| Migration | `datalayer/db/migrate/074_add_checksum_to_media_files.rb` |
| Schema | `datalayer/db/structure.sql` |
| Model | `datalayer/app/models/media_file.rb` |
| Controller | `app/controllers/modules/media_entries/checksum.rb` |
| Controller | `app/controllers/media_entries_controller.rb` |
| Routes | `config/routes.rb` |
| Presenter | `app/presenters/presenters/media_files/media_file.rb` |
| Presenter | `app/presenters/presenters/media_entries/media_entry_show.rb` |
| Frontend | `app/javascript/react/views/MediaEntry/Export.jsx` |
| Translations | `config/locale/translations.csv` |

---

## Architectural Rules (from PR_REVIEW.md)

- All checksum computation happens **server-side only**
- Frontend **never** calculates, stores, or submits checksums
- Verification **never** overwrites the stored reference checksum
- Explicit user action required for both generation and verification
- Backend reads file from **storage**, not from request payload
