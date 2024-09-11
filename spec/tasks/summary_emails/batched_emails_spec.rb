require 'spec_helper'

describe 'produce summary emails tasks' do
  before(:each) do
    Rails.application.load_tasks
    create(:app_setting, site_titles: { en: "Madek", de: "Medienarchiv" })
  end

  context 'batching' do
    it 'works' do
      u1 = FactoryBot.create(:user)
      u2 = FactoryBot.create(:user)
      u3 = FactoryBot.create(:user)
      c1 = NotificationCase.find("transfer_responsibility")

      (Notification::PERIODIC_EMAILS_BATCH_SIZE * 2 + 1).times do
        FactoryBot.create(:notification, notification_case: c1, user: u1)
      end

      (Notification::PERIODIC_EMAILS_BATCH_SIZE + 1).times do
        FactoryBot.create(:notification, notification_case: c1, user: u2)
      end

      Notification::PERIODIC_EMAILS_BATCH_SIZE.times do
        FactoryBot.create(:notification, notification_case: c1, user: u3)
      end

      Rake::Task["madek:produce_daily_emails"].invoke

      subject_title = "Medienarchiv: tägliche Zusammenfassung der Verantwortlichkeits-Übertragungen"

      expect(u1.emails.count).to eq 3
      e1, e2, e3 = u1.emails.order(:created_at)
      expect(e1.subject).to match /^#{subject_title}$/
      expect(e2.subject).to match /^#{subject_title} \(Teil 2\)$/
      expect(e3.subject).to match /^#{subject_title} \(Teil 3\)$/

      expect(u2.emails.count).to eq 2
      e1, e2 = u2.emails.order(:created_at)
      expect(e1.subject).to match /^#{subject_title}$/
      expect(e2.subject).to match /^#{subject_title} \(Teil 2\)$/

      expect(u3.emails.count).to eq 1
      e1, _ = u3.emails.order(:created_at)
      expect(e1.subject).to match /^#{subject_title}$/
    end
  end
end
