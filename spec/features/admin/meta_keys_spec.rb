require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Meta Keys' do
  background do
    @admin_user = create :admin_user, password: 'password'
    sign_in_as @admin_user.login
  end

  scenario 'Sorting meta keys by ID by default', browser: :firefox do
    visit '/admin/meta_keys'

    ids = all('table tbody tr').map do |row|
      row.find('td', match: :first).text
    end

    expect(ids).to eq(ids.sort)
  end
end
