require_relative './_shared'

feature 'App: Infinite Scroll for ResourceLists' do

  let(:user) { User.find_by!(login: 'normin') }

  example 'collections index - as public' do
    100.times { FactoryBot.create(:collection, get_metadata_and_previews: true) }
    open_view_and_check_loading_on_scroll(collections_path, login: false)
  end

  example 'collections index - as user' do
    100.times { FactoryBot.create(:collection, responsible_user: user) }
    sign_in_as user
    open_view_and_check_loading_on_scroll(collections_path)
  end

end
