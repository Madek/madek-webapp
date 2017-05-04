require_relative './_shared'

feature 'App: Infinite Scroll for ResourceLists' do

  let(:user) { User.find_by!(login: 'normin') }

  let(:keyword_link) do
    # create keyword and use it on enough entries so the view will paginate
    kw = create(:keyword)
    100.times.each do
      e = create(
        :media_entry_with_other_media_file, get_metadata_and_previews: true)
      create(:meta_datum_keywords, media_entry: e, keywords: [kw])
    end
    vocabulary_meta_key_term_show_path(
      meta_key_id: kw.meta_key.id, keyword_id: kw.id)
  end

  example 'keyword show - as public' do
    open_view_and_check_loading_on_scroll(keyword_link, login: false)
  end

  example 'keyword show - as user' do
    open_view_and_check_loading_on_scroll(keyword_link)
  end

end
