require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Session' do
  describe 'Signing in' do
    describe 'redirecting to the previous page' do
      given(:user) { create(:user, password: 'password123') }

      context 'when previous page was a private media entry' do
        given(:media_entry) { create(:media_entry_with_image_media_file, responsible_user: user) }

        context 'when user logs in using login box directly' do
          scenario 'user is redirected to media entry page' do
            visit media_entry_path(media_entry)

            expect(page).not_to have_content('grumpy_cat.jpg')

            fill_in 'login', with: user.login
            fill_in 'password', with: 'password123'
            click_button I18n.t(:login_box_login_btn)

            expect(page).to have_css('.ui-body-title', text: 'grumpy_cat.jpg')
          end
        end

        context 'when user goes to login form by clicking the button in the top bar' do
          scenario 'user is redirected to media entry page' do
            visit media_entry_path(media_entry)

            expect(page).not_to have_content('grumpy_cat.jpg')

            within '.ui-header' do
              click_link I18n.t(:user_menu_login_btn)
            end

            fill_in 'login', with: user.login
            fill_in 'password', with: 'password123'
            click_button I18n.t(:login_box_login_btn)

            expect(page).to have_css('.ui-body-title', text: 'grumpy_cat.jpg')
          end
        end
      end

      context 'when previous page was a public media entry' do
        given(:media_entry) do
          create(:media_entry_with_image_media_file, get_metadata_and_previews: true)
        end

        context 'when user goes to login form by clicking the button in the top bar' do
          scenario 'user is redirected to media entry page' do
            visit media_entry_path(media_entry)

            expect(page).to have_css('.ui-body-title', text: 'grumpy_cat.jpg')

            within '.ui-header' do
              click_link I18n.t(:user_menu_login_btn)
            end

            fill_in 'login', with: user.login
            fill_in 'password', with: 'password123'
            click_button I18n.t(:login_box_login_btn)

            expect(page).to have_css('.ui-body-title', text: 'grumpy_cat.jpg')
          end
        end
      end
    end
  end
end
