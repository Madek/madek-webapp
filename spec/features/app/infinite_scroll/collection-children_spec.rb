require_relative './_shared'

feature 'App: Infinite Scroll for ResourceLists' do

  let(:user) { User.find_by!(login: 'normin') }

  example 'collection children - as public' do
    col = FactoryGirl.create(:collection, get_metadata_and_previews: true)
    100.times do
      col.media_entries << FactoryGirl.create(
        :media_entry_with_title, get_metadata_and_previews: true)
    end

    open_view_and_check_loading_on_scroll(collection_path(col), login: false)
  end

  example 'collection children - as user' do
    col = FactoryGirl.create(:collection, responsible_user: user)
    100.times do
      col.media_entries << FactoryGirl.create(
        :media_entry_with_title, responsible_user: user)
    end

    open_view_and_check_loading_on_scroll(collection_path(col))
  end

end
