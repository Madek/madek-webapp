require 'spec_helper'

describe 'seed baseline integrity' do
  it 'restores required notification and smtp defaults' do
    notification_case = NotificationCase.find_by(label: 'transfer_responsibility')
    expect(notification_case).to be_present
    expect(notification_case.allowed_email_frequencies).to include('never', 'daily', 'weekly')

    smtp_setting = SmtpSetting.find_by(id: 0)
    expect(smtp_setting).to be_present
  end
end
