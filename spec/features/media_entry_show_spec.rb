require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaEntry#show' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end

  # TODO: MediaEntry#show integration test
  the_entry = '/entries/e157bedd-c2ba-41d8-8ece-82d73066a11e'

  it 'is rendered' do
    visit the_entry
    #  - title
    expect(page).to have_content 'Title Ausstellung Photo 1'
    # - relations
    #     - parents
    expect(page).to have_content 'Ausstellungen'
    #     - siblings
    expect(page).to have_content 'Ausstellung Gallerie Limatquai '
    # - More Data
    expect(page).to have_content 'import_date 20.04.2012'
    # - File Information
    expect(page).to have_content 'Filename berlin_wall_01.jpg'
  end

  it 'shows correct data' do
    visit the_entry
    #  - title
    expect(page).to have_content 'Title Ausstellung Photo 1'
    # - relations
    #     - parents
    expect(page).to have_content 'Ausstellungen'
    #     - siblings
    expect(page).to have_content 'Ausstellung Gallerie Limatquai '
    # - More Data
    expect(page).to have_content 'import_date 20.04.2012'
    # - File Information
    expect(page).to have_content 'Filename berlin_wall_01.jpg'
  end

end