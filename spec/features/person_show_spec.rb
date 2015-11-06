require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Person#show' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end

  # TODO: Person#show integration test
  normins_page = 'people/8d002622-421c-46c1-957b-bf15dc41a38b'

  it 'is rendered' do
    visit normins_page
  end

  it 'shows correct data' do
    visit normins_page
    #  - title
    expect(page).to have_content 'Normin Normalo'
    # - summary
    expect(page).to have_content 'first_name Normin'
    expect(page).to have_content 'last_name Normalo'
    # - related_via_meta_data_media_resources
    expect(page.find('[data-react-class="UI.Deco.MediaResourcesBox"]')).to be

  end

end
