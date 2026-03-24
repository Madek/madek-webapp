
Randomized with seed 56273

seed baseline integrity
Data from '/ramdisk/ci-working-dir/8da5a925-ff6b-4402-983b-572260454821/datalayer/db/seeds.pgbin' has been restored to                         'madek_webapp_8da5a925-ff6b-4402-983b-572260454821'
  restores required notification and smtp defaults (FAILED - 1)

Failures:

  1) seed baseline integrity restores required notification and smtp defaults
     Failure/Error: expect(notification_case).to be_present
       expected `nil.present?` to be truthy, got false
     # ./spec/seeds_integrity_spec.rb:6:in `block (2 levels) in <top (required)>'

Finished in 0.11085 seconds (files took 2.66 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/seeds_integrity_spec.rb:4 # seed baseline integrity restores required notification and smtp defaults

---

Randomized with seed 10188

produce summary emails tasks
  batching
Data from '/ramdisk/ci-working-dir/49cd84cf-a803-419f-a497-f670351899e4/datalayer/db/seeds.pgbin' has been restored to                         'madek_webapp_49cd84cf-a803-419f-a497-f670351899e4'
    works (FAILED - 1)

Failures:

  1) produce summary emails tasks batching works
     Failure/Error: c1 = NotificationCase.find_by!(label: "transfer_responsibility")

     ActiveRecord::RecordNotFound:
       Couldn't find NotificationCase with [WHERE "notification_cases"."label" = $1]
     # ./spec/tasks/summary_emails/batched_emails_spec.rb:16:in `block (3 levels) in <top (required)>'

Finished in 1.02 seconds (files took 2.61 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/tasks/summary_emails/batched_emails_spec.rb:10 # produce summary emails tasks batching works


--

Randomized with seed 13033

produce summary emails tasks
  produce_weekly_emails task
Data from '/ramdisk/ci-working-dir/5e0ab7bd-7861-4eed-ad3c-3cbbb44151df/datalayer/db/seeds.pgbin' has been restored to                         'madek_webapp_5e0ab7bd-7861-4eed-ad3c-3cbbb44151df'
    works (FAILED - 1)
  produce_daily_emails task
Data from '/ramdisk/ci-working-dir/5e0ab7bd-7861-4eed-ad3c-3cbbb44151df/datalayer/db/seeds.pgbin' has been restored to                         'madek_webapp_5e0ab7bd-7861-4eed-ad3c-3cbbb44151df'
    works (FAILED - 2)

Failures:

  1) produce summary emails tasks produce_weekly_emails task works
     Failure/Error: @c1 = NotificationCase.find_by!(label: "transfer_responsibility")

     ActiveRecord::RecordNotFound:
       Couldn't find NotificationCase with [WHERE "notification_cases"."label" = $1]
     # ./spec/tasks/summary_emails/daily_weekly_emails_spec.rb:23:in `block (2 levels) in <top (required)>'

  2) produce summary emails tasks produce_daily_emails task works
     Failure/Error: @c1 = NotificationCase.find_by!(label: "transfer_responsibility")

     ActiveRecord::RecordNotFound:
       Couldn't find NotificationCase with [WHERE "notification_cases"."label" = $1]
     # ./spec/tasks/summary_emails/daily_weekly_emails_spec.rb:23:in `block (2 levels) in <top (required)>'

Finished in 1.25 seconds (files took 2.59 seconds to load)
2 examples, 2 failures

Failed examples:

rspec ./spec/tasks/summary_emails/daily_weekly_emails_spec.rb:117 # produce summary emails tasks produce_weekly_emails task works
rspec ./spec/tasks/summary_emails/daily_weekly_emails_spec.rb:62 # produce summary emails tasks produce_daily_emails task works