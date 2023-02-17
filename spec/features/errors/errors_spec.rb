require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Errors', ci_group: :error_support do
  let(:user) { create(:user) }

  context 'when support email is configured' do
    background do
      if Settings.madek_support_email.empty?
        raise 'SET the madek_support_email to "support@example.com" to run this test'
      end
    end

    scenario '500' do
      visit error_500_path
      expect(page).to have_content I18n.t(:error_500_title)
      expect(page).to have_content(error_500_message)
      expect(error_500_message).to include('support@example.com')
      expect(page).to have_content 'RuntimeError: error 500'
    end
  end

  context 'when support email is not configured' do
    background do
      allow(Settings).to receive(:madek_support_email) { nil }
    end

    scenario '500' do
      visit error_500_path
      expect(page).to have_content I18n.t(:error_500_title)
      expect(page).to have_content(error_500_message(with_email: false))
      expect(page).to have_content 'RuntimeError: error 500'
    end
  end

  scenario '401' do
    visit my_dashboard_path
    expect(page).to have_content I18n.t(:error_401_title)
  end

  scenario '403' do
    media_entry = FactoryBot.create(:media_entry,
                                     is_published: true,
                                     get_metadata_and_previews: false)
    sign_in_as(user)
    visit media_entry_path(media_entry)
    expect(page).to have_content I18n.t(:error_403_title)
    expect(page).to have_content I18n.t(:error_403_message)
  end
end

def error_500_message(with_email: true)
  if with_email
    I18n.t(:error_500_message_pre) + 'support@example.com' + I18n.t(:error_500_message_post)
  else
    I18n.t(:error_500_message)
  end
end
