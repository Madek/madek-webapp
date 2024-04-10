require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My: Settings' do
  let(:user) { create :user }
  let(:beta_tester_group) { Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID) }

  context 'when user is a member of the beta-tester group' do
    background { beta_tester_group.users << user }

    describe 'Action: index' do
      it 'shows the settings' do
        visit my_settings_path

        sign_in_as user

        expect(page).to have_content(I18n.t(:sitemap_settings))
        expect(page).to have_content(user.email)
      end
    end

    describe 'Action: update' do
      it 'updates the settings' do
        visit my_settings_path

        sign_in_as user

        expect(find('input[name="transfer_responsibility"]:checked').value).to eq('daily')

        choose(I18n.t('settings_notifications_email_frequency_never'))
        expect(find('input[name="transfer_responsibility"]:checked').value).to eq('never')
        click_on(I18n.t(:settings_save_changes))

        visit my_settings_path
        expect(find('input[name="transfer_responsibility"]:checked').value).to eq('never')
      end
    end
  end

  context 'when user is not a member of the beta-tester group' do
    describe 'Action: index' do
      it 'returns an error' do
        visit my_settings_path

        sign_in_as user

        expect(page).not_to have_content(I18n.t(:sitemap_settings))
        expect(page).to have_content("No such dashboard section")
      end
    end
  end

end
