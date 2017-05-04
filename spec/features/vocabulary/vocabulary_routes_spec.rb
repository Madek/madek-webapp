require 'spec_helper_shared'
require 'spec_helper_feature'

# NOTE: extracted from KeywordsController spec, need to test as "feature"!

describe 'Resource: Keywords', type: :feature do
  let(:meta_key) { FactoryGirl.create :meta_key_keywords }

  example 'redirect route works with special characters in terms' do
    terms = ['01.01.2011', '1:1', '1 : 1', 'http://example.com/foo?bar', '~~😎~~']
    terms.each do |term|
      keyword = FactoryGirl.create :keyword, meta_key: meta_key, term: term
      keyword_link = vocabulary_meta_key_term_redirect_path(
        meta_key_id: keyword.meta_key.id, term: keyword.term)

      # NOTE: visiting the path directly does not work bc webdriver normalizes it,
      # removing double-slashes et al. Clicking on a link works tho.
      visit '/release'
      execute_script <<-JS
        document.body.innerHTML = '<a href="#{keyword_link}">#{keyword.term}</a>'
      JS
      click_on term

      expect(page).to have_current_path \
        vocabulary_meta_key_term_show_path(keyword.id)
    end
  end

end
