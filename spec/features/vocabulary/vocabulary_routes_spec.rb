require 'spec_helper_shared'
require 'spec_helper_feature'

# NOTE: extracted from KeywordsController spec, need to test as "feature"!

describe 'Resource: Keywords', type: :feature do
  let(:meta_key) { FactoryGirl.create :meta_key_keywords }

  example 'show route works with special characters in terms' do
    terms = ['01.01.2011', '1:1', '1 : 1', 'http://example.com/foo?bar', '~~😎~~']
    terms.each do |term|
      keyword = FactoryGirl.create :keyword, meta_key: meta_key, term: term

      # NOTE: visiting the path directly does not work bc webdriver normalizes it,
      # removing double-slashes et al. Clicking on the link works tho.
      # visit vocabulary_meta_key_term_path(
      #   meta_key_id: keyword.meta_key.id, term: keyword.term)

      visit vocabulary_keywords_path(meta_key.vocabulary)
      click_on term
      expect(page).to have_current_path filter_by_keyword_path(keyword)
    end
  end

end
