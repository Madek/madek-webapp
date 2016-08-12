require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: Search' do

  describe 'shows search form', browser: false do

    example 'for public' do
      visit search_path
      expect(page.status_code).to eq 200
    end

    example 'for a logged in user' do
      sign_in_as 'normin'
      visit search_path
      expect(page.status_code).to eq 200
    end

  end

  describe 'search results shows entries and links to collections (and back)' do

    it 'for public' do
     search_for_text_and_check_results_pages('kunst')
    end

    it 'empty search (for public)' do
     search_for_text_and_check_results_pages('')
    end

    it 'for a logged in user' do
      sign_in_as 'normin'
      search_for_text_and_check_results_pages('design')
    end

    it 'empty search (for a logged in user)' do
      sign_in_as 'normin'
      search_for_text_and_check_results_pages('')
    end

    it 'switching works after filtering' do
      sign_in_as 'normin'
      search_term = 'design'
      search_for_text(search_term)

      # set a filter
      within('.filter-panel') do
        find('a', text: 'Credits').click
        find('a', text: 'Copyright-Status').click
        find('a', text: 'Urheberrechtlich geschützt').click
        wait_until do
          expect(current_path_with_query).to include 'copyright%3Alicense'
        end
      end

      # switching still works
      go_to_sets
      wait_until do
        entries_results_url = current_path_with_query
        expect(entries_results_url).to eq(
          '/sets?list%5Bfilter%5D=%7B%22search%22%3A%22design%22%7D' \
          '&list%5Bshow_filter%5D=true&list%5Bpage%5D=1&list%5Bper_page%5D=12' \
          '&list%5Border%5D=created_at%20DESC&list%5Blayout%5D=grid')
      end
      go_back_to_entries
    end

  end

end

# helpers

def search_for_text(string)
  visit search_path
  within('.app-body') do
    input = page.find('input[name="search"]')
    expect(input.text).to eq ''
    input.set(string)
    submit_form
  end
  expect_redirect_to_filtered_entries_index(string)
end

def search_for_text_and_check_results_pages(string)
  search_for_text(string)
  go_to_sets
  expect_redirect_to_filtered_sets_index(string)
  go_back_to_entries
end

def expect_redirect_to_filtered_entries_index(string)
  expect(find('.ui-body-title')).to have_content I18n.t(:sitemap_entries)
  entries_results_url = current_path_with_query
  expect(entries_results_url).to eq(
    '/entries?list%5Bfilter%5D=%7B%22search%22%3A%22' \
    + string \
    + '%22%7D&list%5Bshow_filter%5D=true')
end

def go_to_sets
  # Hover on title to make sure no flyout covers the button.
  find('.title-xl').hover

  find('.ui-filterbar .by-center .button-group')
    .find('.button', text: I18n.t(:sitemap_collections))
    .click
end

def expect_redirect_to_filtered_sets_index(string)
  expect(find('.ui-body-title')).to have_content I18n.t(:sitemap_collections)
  sets_results_url = current_path_with_query
  # NOTE: expects filter to be removed for sets!
  expect(sets_results_url).to eq(
    '/sets?list%5Bfilter%5D=%7B%22search%22%3A%22' \
    + string \
    + '%22%7D&list%5Bshow_filter%5D=true&list%5Bpage%5D=1')
end

def go_back_to_entries
  find('.ui-filterbar .by-center .button-group')
    .find('.button', text: I18n.t(:sitemap_entries))
    .click
  expect(find('.ui-body-title')).to have_content I18n.t(:sitemap_entries)
end
