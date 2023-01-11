require_relative '../../shared/basic_data_helper_spec'
require_relative './_shared'

include BasicDataHelper

feature 'App: Infinite Scroll for ResourceLists' do

  background do
    prepare_user

    # Create masses of entries (otherwise there will be no lazy loading)
    (1..75).each do |i|
      create_media_entry "Grumpy #{i}"
    end
  end

  let(:user) { User.find_by!(login: 'normin') }

  example 'entries index - as public' do
    open_view_and_check_loading_on_scroll(media_entries_path, login: false)
  end

  example 'entries index - as user' do
    sign_in_as user
    open_view_and_check_loading_on_scroll(media_entries_path)
  end

end
