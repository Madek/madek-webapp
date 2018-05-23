require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'App: Language switcher' do
  let(:footer) { find '.ui-footer .ui-footer-menu' }

  scenario 'Footer contains select tag with languages' do
    visit root_path

    within footer do
      expect(page).to have_select('lang_switcher',
                                  with_options: ['de', 'en'],
                                  selected: 'de')
    end
  end

  context 'when there is only one available locale' do
    scenario 'Footer does not contain select tag' do
      allow_any_instance_of(AppSetting).to receive(:available_locales) { ['de'] }

      visit root_path

      within footer do
        expect(footer).to have_no_select 'lang_switcher'
      end
    end
  end

  scenario 'Choosing different language' do
    user = User.find_by(login: 'normin')
    sign_in_as user.login

    visit my_dashboard_path

    expect(footer).to have_text 'Sprache wählen'

    select 'en', from: 'lang_switcher'

    expect(page).to have_current_path my_dashboard_path(lang: 'en')
    expect(footer).to have_text 'Choose language'
  end
end
