require 'spec_helper'

describe 'produce summary emails tasks' do
  # aspects to test:
  # - [x] different users & notification cases combinations
  # - [x] notifications with emails already sent are excluded
  # - [x] notifications get the foreign key for the respective email
  # - [x] notifications with user's notification case delivery frequency other than daily are excluded
  # - [x] notifications without user's notification case settings fall back to default delivery frequency
  # - [x] notifications in the summary emails are ordered by `created_at DESC`

  before(:each) do
    Rails.application.load_tasks
    create(:app_setting, site_titles: { en: "Madek", de: "Medienarchiv" })
  end

  before(:each) do
    @u1 = FactoryBot.create(:user)
    @u2 = FactoryBot.create(:user)
    @u3 = FactoryBot.create(:user)

    @c1 = NotificationCase.find("transfer_responsibility")

    FactoryBot.create(:notification_case_user_setting,
                      user: @u3,
                      notification_case: @c1,
                      email_frequency: 'never')

    @n1 = FactoryBot.create(:notification, :with_email,
                            notification_case: @c1, user: @u2)

    @user_1 = FactoryBot.create(:user)
    @set = FactoryBot.create(:collection)
    @n2 = FactoryBot.create(:notification, notification_case: @c1, user: @u1,
                            data: {
                              resource: {
                                link_def: { label: @set.title,
                                            href: "/sets/#{@set.id}" }
                              },
                              user: { fullname: @user_1.to_s }
                            })
    @user_2 = FactoryBot.create(:user)
    @entry = FactoryBot.create(:media_entry)
    @n3 = FactoryBot.create(:notification, notification_case: @c1, user: @u1,
                            data: {
                              resource: {
                                link_def: { label: @entry.title,
                                            href: "/entries/#{@entry.id}" }
                              },
                              user: { fullname: @user_2.to_s }
                            })
    @n4 = FactoryBot.create(:notification, notification_case: @c1, user: @u2)
    @n5 = FactoryBot.create(:notification, notification_case: @c1, user: @u3)
  end

  context 'produce_daily_emails task' do
    it 'works' do
      Madek::Constants::Webapp::DEFAULT_NOTIFICATION_EMAILS_FREQUENCY = :daily
      @tmpl_mod = NotificationCase::EMAIL_TEMPLATES[:transfer_responsibility]
       
      FactoryBot.create(:notification_case_user_setting,
                        user: @u2,
                        notification_case: @c1,
                        email_frequency: 'daily')

      Rake::Task["madek:produce_daily_emails"].invoke

      expect(Email.count).to eq 3 # includes 1 already existing email for @n1
      expect(Email.where(user: @u1).count).to eq 1
      expect(Email.where(user: @u2).count).to eq 1

      expect(@n2.email_id).to eq @n3.email_id
      email = @n2.reload.email

      app_setting = AppSetting.first
      lang = app_setting.default_locale
      site_titles = app_setting.site_titles
      data = { site_titles: site_titles } 

      subject = @tmpl_mod.render_summary_email_subject(lang, data)
      expect(email.subject).to eq subject

      data = { collection: [@n3, @n2].map(&:data) } 
      body = @tmpl_mod.render_summary_email(lang, data)

      expect(email.body).to eq body
    end
  end

  context 'produce_weekly_emails task' do
    it 'works' do
      Madek::Constants::Webapp::DEFAULT_NOTIFICATION_EMAILS_FREQUENCY = :weekly
      @tmpl_mod = NotificationCase::EMAIL_TEMPLATES[:transfer_responsibility]

      FactoryBot.create(:notification_case_user_setting,
                        user: @u2,
                        notification_case: @c1,
                        email_frequency: 'weekly')

      Rake::Task["madek:produce_weekly_emails"].invoke

      expect(Email.count).to eq 3
      expect(Email.where(user: @u1).count).to eq 1
      expect(Email.where(user: @u2).count).to eq 1

      expect(@n2.email_id).to eq @n3.email_id
      email = @n2.reload.email

      app_setting = AppSetting.first
      lang = app_setting.default_locale
      site_titles = app_setting.site_titles
      data = { site_titles: site_titles } 

      subject = @tmpl_mod.render_summary_email_subject(lang, data)
      expect(email.subject).to eq subject

      data = { collection: [@n3, @n2].map(&:data) } 
      body = @tmpl_mod.render_summary_email(lang, data)

      expect(email.body).to eq body
    end
  end
end
