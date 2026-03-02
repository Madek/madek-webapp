# Issue 871: Delegation Notification Actor

Issue: https://github.com/Madek/Madek/issues/871

## Problem

For transfers involving delegations, notifications only showed one sender value.
Requested behavior is to show both source delegation and acting user, for example:

- `... wurde von DELEGATION durch USER an ZIEL übertragen`

For user-origin transfers, legacy/simple wording remains valid.

## Scope and Compare Baseline

Compared this branch against `origin/master` in both repositories:

- `webapp`
- `webapp/datalayer` (nested repo)

This document focuses on functional feature deltas and explicitly notes non-functional generated-asset noise.

## Functional Deltas vs Master

### 1) Controller wiring (webapp)

Files:

- `webapp/app/controllers/modules/resources/resource_transfer_responsibility.rb`
- `webapp/app/controllers/modules/resources/batch_resource_transfer_responsibility.rb`

Change:

- Both single and batch transfer paths now pass `acting_user: current_user` into:
  - `Notification.transfer_responsibility(...)`

Why:

- Backend payload now carries the user who executed the transfer, enabling explicit "durch USER / by USER" wording.

### 2) Notification payload shape (datalayer)

File:

- `webapp/datalayer/app/models/concerns/notifications/transfer_responsibility.rb`

Change:

- Method signature extended with optional keyword `acting_user:`.
- Payload keeps legacy compatibility (`user.fullname`) and additionally sets:
  - `source_user.fullname` for user-origin source
  - `source_delegation.name` for delegation-origin source
  - `acting_user.fullname` when present

Why:

- Distinguishes origin actor model while preserving old consumers and historical data fallback behavior.

### 3) Notification rendering and copy selection (webapp)

Files:

- `webapp/app/javascript/react/views/My/Notifications.jsx`
- `webapp/config/locale/translations.csv`

Change:

- UI now checks for `source_delegation` + `acting_user` and chooses actor-aware text variants.
- Correct actor-aware translation keys used in code:
  - `notifications_message_transfer_responsibility_by_user`
  - `notifications_message_transfer_responsibility_via_delegation_by_user`
- Legacy keys remain and are still used as fallback when new fields are absent:
  - `notifications_message_transfer_responsibility`
  - `notifications_message_transfer_responsibility_via_delegation`

Important correction:

- Earlier draft text in this issue file referenced non-existent key names with `*_from_delegation*`.
- Implemented keys are the `*_by_user` variants listed above.

### 4) Email template wording (datalayer)

Files:

- `webapp/datalayer/app/lib/email_templates/transfer_responsibility.rb`
- `webapp/datalayer/spec/lib/email_templates/transfer_responsibility_spec.rb`

Change:

- `single_event` now prefers explicit source fields and renders:
  - delegation-origin + actor: `from SOURCE_DELEGATION by ACTING_USER to TARGET`
  - fallback: legacy `from SOURCE_USER to TARGET`
- DE and EN summary specs now assert delegation+actor wording.

### 5) Search hardening relevant to observed failures (datalayer)

File:

- `webapp/datalayer/app/models/concerns/filter_by_search_term.rb`

Change:

- Tokenization now returns an array and removes blank tokens.
- Query builder returns early if tokens are empty.
- SQL uses typed array casting (`ARRAY[?]::text[]`) via sanitization.

Why:

- Prevents PostgreSQL `PG::IndeterminateDatatype` from whitespace-only search terms causing `ILIKE ALL (array[])`.

## Spec Changes vs Master

### Updated / added assertions

- `webapp/spec/features/transfer_responsibility/transfer_responsibility_shared.rb`
  - payload assertions now validate:
    - user-origin notifications contain `source_user` + `acting_user`
    - delegation-origin notifications contain `source_delegation` + `acting_user`
  - selection now matches by resource label in payload to avoid ambiguity

- `webapp/spec/features/transfer_responsibility/transfer_responsibility_from_delegation_spec.rb`
  - recipient user is explicitly placed in beta-testers notification group
  - batch scenarios now assert notifications for all mixed-responsibility sources

- `webapp/spec/features/my/my_notifications_spec.rb`
  - added actor-aware rendering scenarios for:
    - personal section (`... an Sie`)
    - delegation section (`... an <delegation>`)
  - test data timestamps adjusted to avoid hidden/collapsed-date false negatives

## Occurred Issues During Implementation / Testing

### 1) Whitespace search caused SQL 500

Observed:

- `PG::IndeterminateDatatype` with `ILIKE ALL (array[])`
- Request example:
  - `search_term: " "`
  - `search_also_in_person: "true"`

Impact:

- User autocomplete request failed (500), disrupting transfer UI flow.

Resolution:

- Hardened tokenization/query building in `filter_by_search_term.rb` (empty-token guard + typed array SQL).

### 2) Downstream batch notification failure (`notif` was `nil`)

Observed in:

- `spec/features/transfer_responsibility/transfer_responsibility_from_delegation_spec.rb`

Root cause:

- Notification assertion failure was downstream from interrupted transfer flow (triggered by autocomplete 500 above).

Resolution:

- Fixing search crash restored transfer completion and notification creation path.

### 3) Beta-gating mismatch in delegation batch test setup

Observed:

- Notification creation is beta-gated (`beta_tester_notifications?` checks).
- Test recipient not in beta group resulted in no created notification.

Resolution:

- Added recipient to beta-testers notifications group in scenario setup.

### 4) UI assertion false negative due collapsed date groups

Observed:

- Notification row existed but not visible in default collapsed date bucket (>3/day behavior).

Resolution:

- Placed test notifications on non-collapsed date buckets (or equivalently ensure expansion before assert).

### 5) Environment bootstrap blocker (non-feature code)

Observed:

- `PgTasks.data_restore` failure (`relation "public.admins" does not exist`) in some local runs.

Impact:

- Specs failed before exercising feature logic.

Status:

- Treated as environment/schema-seed consistency issue, not as a feature regression in Issue 871 logic.

## Non-Functional Compare Noise

Generated assets in `webapp/public/assets` may differ from master due to serialization/build toolchain details (example: YAML scalar style quoted string vs `>-` folded style for locale text).

- This is non-functional formatting drift unless translation content itself differs.
- Keep this separate from feature behavior conclusions.

## Suggested Verification

From `webapp`:

```bash
bundle exec rspec \
  spec/features/my/my_notifications_spec.rb \
  spec/features/transfer_responsibility/transfer_responsibility_media_entry_spec.rb \
  spec/features/transfer_responsibility/transfer_responsibility_collection_spec.rb \
  spec/features/transfer_responsibility/transfer_responsibility_from_delegation_spec.rb
```

From `webapp/datalayer`:

```bash
bundle exec rspec spec/lib/email_templates/transfer_responsibility_spec.rb
```

