require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'App: UserMenu' do

  describe 'depending on logged-in status' do

    example 'shows user menu with name when logged in' do
      sign_in_as('normin')
      expect(user_menu_toggle).to have_content 'Normin Normalo'
    end

  end

  describe 'content of user menu' do

    example 'links' do
      user = sign_in_as('normin')
      open_user_menu
      links = user_menu_drop_menu.all('a')
        .map { |i| URI.parse(i[:href]).path.presence }.compact
      expect(links).to eq [
        '/my/upload',
        '/my/unpublished_entries',
        '/my/clipboard',
        '/my/content_media_entries',
        '/my/content_collections',
        '/my/favorite_media_entries',
        '/my/favorite_collections',
        '/people/' + user.person.id,
        '/my/groups']
    end

    example 'logout action' do
      sign_in_as('normin')
      open_user_menu
      user_menu_drop_menu.click_on I18n.t(:user_menu_logout_btn)
      expect(page).to have_content(I18n.t(:app_notice_logged_out))
    end

    example 'shows admin menu if user is admin' do
      sign_in_as('adam')
      open_user_menu
      expect(user_menu_drop_menu).to have_selector('a[href="/admin"]')
      expect(user_menu_drop_menu).to \
        have_content(I18n.t(:user_menu_admin_mode_toogle_on))
    end

    example 'doesnt show admin menu if user is not admin' do
      sign_in_as('normin')
      open_user_menu
      expect(user_menu_drop_menu).to_not have_selector('a[href="/admin"]')
      expect(user_menu_drop_menu).to_not \
        have_content(I18n.t(:user_menu_admin_mode_toogle_on))
    end

  end

  describe 'usability' do

    example 'JS: opens on click' do
      sign_in_as('normin')
      open_user_menu
      expect(user_menu_drop_menu).to be_visible
    end

    example 'NO-JS: opens on hover', browser: :firefox_nojs do
      sign_in_as('normin')
      user_menu_toggle.hover
      expect(user_menu_drop_menu).to be_visible
    end

  end
end

# helpers

def user_menu
  page.find('.ui-header .ui-header-user')
end

def user_menu_toggle
  user_menu.find('.dropdown-toggle')
end

def user_menu_drop_menu
  user_menu.find('.ui-drop-menu')
end

def open_user_menu
  user_menu_toggle.click
end
