require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MediaEntryPermissionsShared

feature 'Resource: MediaEntry' do
  given(:user) { create(:user, password: 'password') }

  background do
    create(:delegation, name: 'Awesome Group')
    create(:delegation, name: 'Ordinary Group')
    @entry = create(:media_entry_with_image_media_file,
                    responsible_user: user)

    sign_in_as user.login
  end

  scenario 'shows user email in search autocomplete' do
    user = create(:user, login: 'alice', email: 'user@example.com')

    open_permission_editable
    within('.ui-rights-body', text: I18n.t(:permission_subject_title_users_or_delegations)) do
      input = find('input')
      input.click
      input.set(user.login)
      results = find('.ui-autocomplete .ui-menu-item', text: user.email)
      expect(results).to be
      visit('about:blank')
      accept_confirm
    end
  end

  scenario 'shows delegations in search autocomplete' do
    open_permission_editable

    within('.ui-rights-body', text: I18n.t(:permission_subject_title_users_or_delegations)) do
      input = find('input')
      input.click
      input.set('group')
    end

    expect_delegation_in_autocomplete('Awesome Group')
    expect_delegation_in_autocomplete('Ordinary Group')
  end

end

def expect_delegation_in_autocomplete(label)
  within '.ui-autocomplete' do
    expect(page).to have_css('.ui-menu-item',
                             text: label + I18n.t('app_autocomplete_user_delegation_postfix'))
  end
end
