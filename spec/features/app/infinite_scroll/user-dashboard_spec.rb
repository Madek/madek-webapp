require_relative './_shared'

feature 'App: Infinite Scroll for ResourceLists' do

  let(:user) { User.find_by!(login: 'normin') }

  example 'user dashboard section' do
    100.times do
      FactoryBot.create(:media_entry_with_title, responsible_user: user)
    end

    open_view_and_check_loading_on_scroll(
      my_dashboard_section_path(:content_media_entries))
  end

end
