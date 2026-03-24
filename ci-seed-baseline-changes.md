# CI Seed Baseline Changes (Summary Email Specs)

## Why this change was needed

CI was failing in summary email specs because the restored test seed snapshot did not reliably provide required baseline rows (notably `notification_cases.transfer_responsibility` and `smtp_settings.id = 0`).

A global test workaround had been added to backfill these rows during every spec run, but that masked real seed regressions.

## What was changed

### 1) Removed global runtime backfill in test bootstrap

Updated `spec/spec_helper.rb`:

- Removed helper `ensure_seed_baseline`
- Removed `ensure_seed_baseline` invocation from global `before(:each)`

This ensures specs reflect the true content restored from `datalayer/db/seeds.pgbin`.

### 2) Kept explicit NotificationCase lookup style

These call sites use explicit lookup by label:

- `spec/tasks/summary_emails/batched_emails_spec.rb`
- `spec/tasks/summary_emails/daily_weekly_emails_spec.rb`
- `datalayer/app/models/concerns/notifications/transfer_responsibility.rb`

Pattern: `NotificationCase.find_by!(label: "transfer_responsibility")`

### 3) Added seed integrity guard spec

Added `spec/seeds_integrity_spec.rb` to fail fast if required seed baseline is missing.

Checks:

- `NotificationCase` exists with label `transfer_responsibility`
- `allowed_email_frequencies` includes `never`, `daily`, `weekly`
- `SmtpSetting` exists with `id = 0`

## Validation performed

Ran targeted specs:

- `spec/tasks/summary_emails/batched_emails_spec.rb`
- `spec/tasks/summary_emails/daily_weekly_emails_spec.rb`
- `spec/seeds_integrity_spec.rb`

Result: **4 examples, 0 failures**

## Outcome

- CI now fails for actual seed integrity problems instead of hiding them through global test mutations.
- Summary email specs depend on real restored seed state.
