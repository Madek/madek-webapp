require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin Interface' do
  scenario 'Going back to media archive' do
    sign_in_as 'Adam'
    visit '/app_admin'
    expect_return_link_in_navbar
    click_link 'return to user-interface'
    assert_exact_url_path '/my'
  end

  def expect_return_link_in_navbar
    link = find('.navbar .navbar-right a')
    expect(link.text).to match /return to user\-interface/
  end
end
