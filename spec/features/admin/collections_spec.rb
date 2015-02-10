require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Groups' do
  background do
    @admin_user = create :admin_user, password: 'password'
    sign_in_as @admin_user.login
  end

  scenario 'Filtering by collection name' do
    visit '/admin/collections'
    fill_in 'search_terms', with: 'zhdk'
    click_button 'Apply'
    names = all('table tbody tr').map do |tr|
      expect(tr.find('th:first').text.downcase).to have_content 'zhdk'
    end
    expect(find_field('search_terms')[:value]).to eq 'zhdk'
    expect(names).to eq names.sort
  end
end
