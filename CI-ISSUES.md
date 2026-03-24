ruby 3.3.8 is already installed

Randomized with seed 42726

produce summary emails tasks
  batching
Data from '/ramdisk/ci-working-dir/7364b5c9-e830-46e4-b1b1-b9401b5ec7d6/datalayer/db/seeds.pgbin' has been restored to                         'madek_webapp_7364b5c9-e830-46e4-b1b1-b9401b5ec7d6'
    works (FAILED - 1)

Failures:

  1) produce summary emails tasks batching works
     Failure/Error: c1 = NotificationCase.find("transfer_responsibility")

     ActiveRecord::RecordNotFound:
       Couldn't find NotificationCase with 'label'="transfer_responsibility"
     # ./spec/tasks/summary_emails/batched_emails_spec.rb:16:in `block (3 levels) in <top (required)>'

Finished in 0.78658 seconds (files took 2.68 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/tasks/summary_emails/batched_emails_spec.rb:10 # produce summary emails tasks batching works


-------






ruby 3.3.8 is already installed

Randomized with seed 14823

produce summary emails tasks
  produce_daily_emails task
Data from '/ramdisk/ci-working-dir/47adabee-dd29-4218-9640-80c46bcaf8da/datalayer/db/seeds.pgbin' has been restored to                         'madek_webapp_47adabee-dd29-4218-9640-80c46bcaf8da'
    works (FAILED - 1)
  produce_weekly_emails task
Data from '/ramdisk/ci-working-dir/47adabee-dd29-4218-9640-80c46bcaf8da/datalayer/db/seeds.pgbin' has been restored to                         'madek_webapp_47adabee-dd29-4218-9640-80c46bcaf8da'
    works (FAILED - 2)

Failures:

  1) produce summary emails tasks produce_daily_emails task works
     Failure/Error: @c1 = NotificationCase.find("transfer_responsibility")

     ActiveRecord::RecordNotFound:
       Couldn't find NotificationCase with 'label'="transfer_responsibility"
     # ./spec/tasks/summary_emails/daily_weekly_emails_spec.rb:23:in `block (2 levels) in <top (required)>'

  2) produce summary emails tasks produce_weekly_emails task works
     Failure/Error: @c1 = NotificationCase.find("transfer_responsibility")

     ActiveRecord::RecordNotFound:
       Couldn't find NotificationCase with 'label'="transfer_responsibility"
     # ./spec/tasks/summary_emails/daily_weekly_emails_spec.rb:23:in `block (2 levels) in <top (required)>'

Finished in 1.33 seconds (files took 2.54 seconds to load)
2 examples, 2 failures

Failed examples:

rspec ./spec/tasks/summary_emails/daily_weekly_emails_spec.rb:62 # produce summary emails tasks produce_daily_emails task works
rspec ./spec/tasks/summary_emails/daily_weekly_emails_spec.rb:117 # produce summary emails tasks produce_weekly_emails task works