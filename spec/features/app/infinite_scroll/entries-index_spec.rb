require_relative './_shared'

feature 'App: Infinite Scroll for ResourceLists' do

  let(:user) { User.find_by!(login: 'normin') }

  example 'entries index - as public' do
    open_view_and_check_loading_on_scroll(media_entries_path, login: false)
  end

  example 'entries index - as user' do
    sign_in_as user
    open_view_and_check_loading_on_scroll(media_entries_path)
  end

end
