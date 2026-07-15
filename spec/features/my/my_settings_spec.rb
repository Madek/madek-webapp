require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My: Settings' do
  let(:user) { create :user, settings: { "unrelated" => "kept" } }
  let(:beta_tester_group) { Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID) }

  context 'when user is a member of the beta-tester group' do
    background { beta_tester_group.users << user }

    describe 'Action: index' do
      it 'shows the settings' do
        visit my_settings_path
        sign_in_as user

        expect(page).to have_content(I18n.t(:sitemap_settings))
        expect(page).to have_content(I18n.t(:settings_advanced_functions_title))
        expect(page).to have_content(
          I18n.t(:settings_show_all_data_tab_in_edit_mode_label))
        expect(page).to have_content(user.email)

        headings = all('.ui-resources-holder h2').map(&:text)
        expect(headings.index(I18n.t(:settings_notifications_title))).to be <
          headings.index(I18n.t(:settings_advanced_functions_title))

        # (see 'Action: update' for more detailed display tests)
      end
    end

    describe 'Action: update' do
      it 'updates the settings' do
        visit my_settings_path
        sign_in_as user

        # old state
        expect(page).to have_select('emailsLocale', selected: 'Deutsch',
                                  with_options: ['Deutsch', 'Englisch'])
        expect(page).to have_unchecked_field('showAllDataTabInEditMode')
        expect(find('input[name="transfer_responsibility"]:checked').value).to eq('daily')

        # change
        check('showAllDataTabInEditMode')
        select 'Englisch', from: 'emailsLocale'
        choose(I18n.t('settings_notifications_email_frequency_never'))
        expect(find('input[name="transfer_responsibility"]:checked').value).to eq('never')
        click_on(I18n.t(:settings_save_changes))

        # new state
        visit my_settings_path
        expect(page).to have_checked_field('showAllDataTabInEditMode')
        expect(user.reload.settings).to include(
          "show_all_data_tab_in_edit_mode" => true,
          "unrelated" => "kept")
        expect(page).to have_select('emailsLocale',  selected: 'Englisch')
        expect(find('input[name="transfer_responsibility"]:checked').value).to eq('never')
      end
    end
  end

  context 'when user is not a member of the beta-tester group' do
    describe 'Action: index' do
      it 'shows the archive settings' do
        visit my_settings_path
        sign_in_as user

        expect(page).to have_content(I18n.t(:sitemap_settings))
        expect(page).to have_content(I18n.t(:settings_advanced_functions_title))
        expect(page).to have_content(
          I18n.t(:settings_show_all_data_tab_in_edit_mode_label))
        expect(page).to have_unchecked_field('showAllDataTabInEditMode')
        expect(page).not_to have_content(I18n.t(:settings_notifications_title))
      end
    end

    describe 'Action: update' do
      it 'updates the archive settings' do
        visit my_settings_path
        sign_in_as user

        check('showAllDataTabInEditMode')
        click_on(I18n.t(:settings_save_changes))

        visit my_settings_path
        expect(page).to have_checked_field('showAllDataTabInEditMode')
        expect(user.reload.settings).to include(
          "show_all_data_tab_in_edit_mode" => true,
          "unrelated" => "kept")
      end
    end
  end

end
