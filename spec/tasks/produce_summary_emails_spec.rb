require 'spec_helper'

describe 'produce summary emails tasks' do
  before(:each) do
    Rails.application.load_tasks
    create(:app_setting, site_titles: { en: "Madek", de: "Medienarchiv" })
  end

  before(:each) do
    @u1 = FactoryBot.create(:user)
    @u2 = FactoryBot.create(:user)
    @u3 = FactoryBot.create(:user)
    @u4 = FactoryBot.create(:user)

    @notif_email = Faker::Internet.email
    @d1 = FactoryBot.create(:delegation)
    @d1.supervisors << @u1
    @d2 = FactoryBot.create(:delegation, notifications_email: @notif_email)
    @d2.supervisors << @u1
    @d3 = FactoryBot.create(:delegation, notifications_email: @notif_email)
    @d3.supervisors << @u1

    @c1 = NotificationCase.find("transfer_responsibility")

    FactoryBot.create(:notification_case_user_setting,
                      user: @u3,
                      notification_case: @c1,
                      email_frequency: 'never')

    @n1 = FactoryBot.create(:notification, :with_email, notification_case: @c1, user: @u2)
    @n2 = FactoryBot.create(:notification, notification_case: @c1, user: @u1)
    @n3 = FactoryBot.create(:notification, notification_case: @c1, user: @u1)
    @n4 = FactoryBot.create(:notification, notification_case: @c1, user: @u2)
    @n5 = FactoryBot.create(:notification, notification_case: @c1, user: @u3)
    @n6 = FactoryBot.create(:notification, notification_case: @c1, user: @u1, via_delegation: @d1)
    @n7 = FactoryBot.create(:notification, notification_case: @c1, user: @u1, via_delegation: @d2)
    @n8 = FactoryBot.create(:notification, notification_case: @c1, user: @u1, via_delegation: @d3)
    @n9 = FactoryBot.create(:notification, notification_case: @c1, user: nil, via_delegation: @d2)
    @n10 = FactoryBot.create(:notification, notification_case: @c1, user: nil, via_delegation: @d3)
    @n11 = FactoryBot.create(:notification, notification_case: @c1, user: @u1, via_delegation: @d3,
                             created_at: 8.days.ago)
    @n12 = FactoryBot.create(:notification, notification_case: @c1, user: @u4)
  end

  context 'produce_daily_emails task' do
    # notifications:
    # +-----+----+----+--------------------+------------------+
    # | n1  | u2 |    | e0 (done before)   | daily (default)  |
    # | n2  | u1 |    | e1                 | daily (default)  |
    # | n3  | u1 |    | e1                 | daily (default)  |
    # | n4  | u2 |    | e2                 | daily (default)  |
    # | n5  | u3 |    | not sent (setting) | never (setting)  |
    # | n6  | u1 | d1 | e1                 | daily (default)  |
    # | n7  | u1 | d2 | e1                 | daily (default)  |
    # | n8  | u1 | d3 | e1                 | daily (default)  |
    # | n9  |    | d2 | e3 (notif email)   | daily (default)  |
    # | n10 |    | d3 | e4 (notif email)   | daily (default)  |
    # | n11 | u1 |    | not sent (too old) | daily (default)  |
    # | n12 | u4 |    | not sent (setting) | weekly (setting) |
    # +-----+----+----+--------------------+------------------+

    it 'works' do
      Madek::Constants::DEFAULT_NOTIFICATION_EMAILS_FREQUENCY = :daily
       
      FactoryBot.create(:notification_case_user_setting,
                        user: @u4,
                        notification_case: @c1,
                        email_frequency: 'weekly')

      Rake::Task["madek:produce_daily_emails"].invoke

      expect(Email.count).to eq 5 # includes 1 already existing email for @n1
      @e0 = @n1.email

      [@n1, @n2, @n3, @n4, @n5, @n6, @n7, @n8, @n9, @n10, @n11, @n12].each(&:reload)

      @e1 = @n2.email
      expect(@u1.emails.map(&:id)).to eq [@e1.id]
      expect(@n3.email_id).to eq @e1.id
      expect(@n6.email_id).to eq @e1.id
      expect(@n7.email_id).to eq @e1.id
      expect(@n8.email_id).to eq @e1.id
      
      @e2 = @n4.email
      expect(@u2.emails.map(&:id)).to eq [@e2.id]

      @e3 = @n9.email
      expect(@d2.emails.map(&:id)).to eq [@e3.id]

      @e4 = @n10.email
      expect(@d3.emails.map(&:id)).to eq [@e4.id]

      expect(@u4.emails).to be_empty

      expect([@e0, @e1, @e2, @e3, @e4].compact.uniq.count).to eq 5
    end
  end

  context 'produce_weekly_emails task' do
    # notifications:
    # +-----+----+----+--------------------+------------------+
    # | n1  | u2 |    | e0 (done before)   | weekly (default) |
    # | n2  | u1 |    | e1                 | weekly (default) |
    # | n3  | u1 |    | e1                 | weekly (default) |
    # | n4  | u2 |    | e2                 | weekly (default) |
    # | n5  | u3 |    | not sent (setting) | never (setting)  |
    # | n6  | u1 | d1 | e1                 | weekly (default) |
    # | n7  | u1 | d2 | e1                 | weekly (default) |
    # | n8  | u1 | d3 | e1                 | weekly (default) |
    # | n9  |    | d2 | e3 (notif email)   | weekly (default) |
    # | n10 |    | d3 | e4 (notif email)   | weekly (default) |
    # | n11 | u1 |    | not sent (too old) | weekly (default) |
    # | n12 | u4 |    | not sent (setting) | daily (setting)  |
    # +-----+----+----+--------------------+------------------+

    it 'works' do
      Madek::Constants::DEFAULT_NOTIFICATION_EMAILS_FREQUENCY = :weekly

      FactoryBot.create(:notification_case_user_setting,
                        user: @u4,
                        notification_case: @c1,
                        email_frequency: 'daily')

      Rake::Task["madek:produce_weekly_emails"].invoke

      expect(Email.count).to eq 3 # includes 1 already existing email for @n1
      @e0 = @n1.email

      [@n1, @n2, @n3, @n4, @n5, @n6, @n7, @n8, @n9, @n10, @n11].each(&:reload)

      @e1 = @n2.email
      expect(@u1.emails.map(&:id)).to eq [@e1.id]
      expect(@n3.email_id).to eq @e1.id
      expect(@n6.email_id).to eq @e1.id
      expect(@n7.email_id).to eq @e1.id
      expect(@n8.email_id).to eq @e1.id
      
      @e2 = @n4.email
      expect(@u2.emails.map(&:id)).to eq [@e2.id]

      expect(@n9.email).not_to be
      expect(@n10.email).not_to be

      expect(@u4.emails).to be_empty

      expect([@e0, @e1, @e2].compact.uniq.count).to eq 3
    end
  end
end
