require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'FilterSet#create' do

  it 'can be created from a MediaEntry#index', browser: :firefox do
    @user = User.find_by(login: 'normin')
    the_filter = '{"meta_data":[{"key":"madek_core:title","match":"diplom"}]}'
    the_title = Faker::Lorem.words(3).join(' ')

    sign_in_as @user.login
    visit media_entries_path

    within('[data-react-class="UI.Deco.MediaResourcesBox"]') do
      find('.filter-panel textarea').set(the_filter)
      submit_form
      # reloads page
      within('.ui-toolbar') do
        find('span', text: 'Save!').click
      end
    end

    accept_prompt('Name?', with: the_title)

    # TODO: remove sleep and wait for appearance of success alert.
    sleep 3
    fs = FilterSet.order('created_at DESC').first

    expect(current_path).to eq filter_set_path(fs)
    expect(fs.title).to eq the_title
    expect(fs.definition).to eq JSON.parse(the_filter)
  end

end
