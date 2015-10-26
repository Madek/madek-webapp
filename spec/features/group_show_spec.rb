require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Group#show' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end

  # TODO: Group#show integration test
  the_zhdk_group = 'f7cc8c56-5b32-4f23-9a29-8e5c22f8cafc'

  it 'is rendered' do
    visit my_group_path(the_zhdk_group)
  end

  it 'shows title and summary' do
    visit my_group_path(the_zhdk_group)
    #  - title
    expect(page).to have_content 'ZHdK'
    # - summary
    expect(page).to have_content "#{I18n.t(:group_meta_data_name)} ZHdK"
  end

end
