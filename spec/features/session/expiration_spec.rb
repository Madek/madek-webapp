require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Feature: Session' do
  background do
    user = create(:user)
    sign_in_as user.login, user.password
  end

  describe 'Expiration of Session after configured timeout' do
    describe 'when application has a session timeout 10 seconds' do
      specify 'the user is logged out after 12 seconds' do
        visit '/my'
        expect(page).to have_content I18n.t(:sitemap_my_groups)
        expect(page).not_to have_content I18n.t(:error_401_title)
        AuthSystem.all.update(session_max_lifetime_hours: 0)
        visit current_path
        expect(page).not_to have_content I18n.t(:sitemap_my_groups)
        expect(page).to have_content I18n.t(:error_401_title)
      end
    end
  end

  describe 'Flash notification if session expiring soon' do
    specify 'red' do
      AuthSystem.all.update(session_max_lifetime_hours: 0.1)
      visit '/my'
      find('.ui-alert.error',
           text: 'Sie werden in weniger als 10 Minuten ausgeloggt. Speichern Sie Ihre Eingaben und melden sich neu an.')
    end

    specify 'orange' do
      AuthSystem.all.update(session_max_lifetime_hours: 0.3)
      visit '/my'
      find('.ui-alert.warning',
           text: 'Sie werden in weniger als 30 Minuten ausgeloggt. Speichern Sie Ihre Eingaben und melden sich neu an.')
    end
  end
end
