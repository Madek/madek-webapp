require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'App: Infinite Scroll for ResourceLists', browser: :firefox do

  example 'entries index - as public' do
    open_view_and_check_loading_on_scroll(media_entries_path)
  end

  example 'entries index - as user' do
    sign_in_as 'normin'

    open_view_and_check_loading_on_scroll(media_entries_path)
  end

  example 'collections index - as public' do
    100.times { FactoryGirl.create(:collection, get_metadata_and_previews: true) }

    open_view_and_check_loading_on_scroll(collections_path)
  end

  example 'collections index - as user' do
    user = sign_in_as 'normin'
    100.times { FactoryGirl.create(:collection, responsible_user: user) }

    open_view_and_check_loading_on_scroll(collections_path)
  end

  example 'collection children - as public' do
    col = FactoryGirl.create(:collection, get_metadata_and_previews: true)
    100.times do
      col.media_entries << FactoryGirl.create(
        :media_entry_with_title, get_metadata_and_previews: true)
    end

    open_view_and_check_loading_on_scroll(collection_path(col))
  end

  example 'collection children - as user' do
    user = sign_in_as 'normin'
    col = FactoryGirl.create(:collection, responsible_user: user)
    100.times do
      col.media_entries << FactoryGirl.create(
        :media_entry_with_title, responsible_user: user)
    end

    open_view_and_check_loading_on_scroll(collection_path(col))
  end

  example 'user dashboard section' do
    user = sign_in_as 'normin'
    100.times do
      FactoryGirl.create(:media_entry_with_title, responsible_user: user)
    end

    open_view_and_check_loading_on_scroll(
      my_dashboard_section_path(:content_media_entries))
  end

end

# helpers #########################################################################

def open_view_and_check_loading_on_scroll(path)
  visit path

  box = find('.ui-resources')
  last_visible_page_n = page_number(last_page(box))

  scroll_to_last_page
  # wait maximum 30 seconds for at least one more page to load:
  wait_until(30) do
    last_visible_page_n < page_number(last_page(box))
  end
end

def last_page(box)
  box.all('.ui-resources-page').last
end

def page_number(box_page)
  box_page.find('.ui-resources-page-counter')
    .text.split.map(&:to_i).select(&:nonzero?).first
end

def scroll_to_last_page
  page.execute_script <<-JSCODE
    pages = document.querySelectorAll('.ui-resources .ui-resources-page')
    lastPage = pages[pages.length-1]
    window.scrollTo(0, lastPage.offsetTop)
  JSCODE
end
