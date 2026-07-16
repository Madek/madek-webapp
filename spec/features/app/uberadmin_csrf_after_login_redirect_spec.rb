require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

# Regression spec for #870 (Fehler bei Wechsel zu Überadmin).
# test env normally disables both CSRF checks (`allow_forgery_protection = false`)
# and Rails.cache (`:null_store`), so this repro forces both on to actually
# exercise the code path.
feature 'App: Uberadmin toggle CSRF (#870)' do
  around do |example|
    original_forgery = ActionController::Base.allow_forgery_protection
    original_cache = Rails.cache
    ActionController::Base.allow_forgery_protection = true
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    example.run
  ensure
    ActionController::Base.allow_forgery_protection = original_forgery
    Rails.cache = original_cache
  end

  example 'toggling uberadmin right after login-redirect from a forbidden page does not 422' do
    entry = MediaEntry.find('71196fee-abdb-41c1-98f7-48d62c9f0ae7')
    admin = User.find_by!(login: 'adam')

    visit media_entry_path(entry)

    within '#login_menu' do
      fill_in 'email-or-login', with: admin.login
      click_on 'Anmelden'
    end
    within '#login_menu' do
      fill_in 'password', with: 'password'
      click_on 'Anmelden'
    end

    expect(page).to have_content I18n.t(:error_403_title)

    user_menu.find('.dropdown-toggle').click
    user_menu.click_on(I18n.t(:user_menu_admin_mode_toogle_on))

    expect(page).not_to have_content('InvalidAuthenticityToken')
    expect(page)
      .to have_selector '.ui-alert.success', text: 'Admin-Modus aktiviert!'
  end

  example 'a blank session whose first render is an error page still persists a session cookie' do
    entry = MediaEntry.find('71196fee-abdb-41c1-98f7-48d62c9f0ae7')
    admin = User.find_by!(login: 'adam')

    # Mirrors what the separate auth app does on every sign-in: it explicitly
    # expires webapp's own Rails session cookie in its response
    # (madek/auth/cljc-src/madek/auth/http/session.clj -> create-user-session-response),
    # so the very next webapp request starts from a genuinely blank session,
    # whose first render here is a 403 (rendered via ShowExceptions/exceptions_app).
    sign_in_as admin
    page.driver.browser.manage.delete_cookie(Madek::Constants::Webapp::SESSION_NAME)
    visit media_entry_path(entry)
    expect(page).to have_content I18n.t(:error_403_title)

    session_cookie = page.driver.browser.manage.cookie_named(Madek::Constants::Webapp::SESSION_NAME)
    expect(session_cookie[:value]).to be_present

    user_menu.find('.dropdown-toggle').click
    user_menu.click_on(I18n.t(:user_menu_admin_mode_toogle_on))

    expect(page).not_to have_content('InvalidAuthenticityToken')
    expect(page)
      .to have_selector '.ui-alert.success', text: 'Admin-Modus aktiviert!'
  end

  example 'toggling uberadmin after login -> logout -> login does not 422' do
    admin = User.find_by!(login: 'adam')

    sign_in_as admin
    open_user_menu
    user_menu.click_on(I18n.t(:user_menu_logout_btn))

    sign_in_as admin
    open_user_menu
    user_menu.click_on(I18n.t(:user_menu_admin_mode_toogle_on))

    expect(page).not_to have_content('InvalidAuthenticityToken')
    expect(page)
      .to have_selector '.ui-alert.success', text: 'Admin-Modus aktiviert!'
  end
end

def user_menu
  page.find('.ui-header .ui-header-user')
end

def open_user_menu
  user_menu.find('.dropdown-toggle').click
end
