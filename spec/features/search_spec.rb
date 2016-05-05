require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: Search' do

  describe 'shows search form' do

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

  describe 'search results', browser: :firefox do

    it 'for public' do
      search_for_text('kunst')
    end

    it 'for a logged in user' do
      sign_in_as 'normin'
      search_for_text('design')
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
  # expect redirect to filtered index
  expect(current_path_with_query).to eq(
    '/entries?list%5Bfilter%5D=%7B%22search%22%3A%22' \
    + string \
    + '%22%7D&list%5Bshow_filter%5D=true')
end
