require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Media Entries' do
  scenario 'Browsing similar media entries', browser: :firefox do
    sign_in_as 'Normin'
    visit media_resources_path
    expect_media_entry
    expect_possibility_to_browse_similar_media_entries
  end

  def expect_media_entry
    find_first_media_entry_element
    expect( find_first_media_entry_element.text ).not_to be_empty
  end

  def expect_possibility_to_browse_similar_media_entries
    media_entry = MediaEntry.find( find_first_media_entry_element[:"data-id"] )
    move_mouse_over(find(".ui-resource[data-type='media-entry'] .ui-thumbnail-meta", match: :first))
    find(".ui-resource[data-type='media-entry'] .ui-thumbnail-action-browse", match: :first).click
    assert_exact_url_path browse_media_resource_path(media_entry)
    expect(page).to have_content('Nach vergleichbaren Inhalten stöbern')
  end

  def find_first_media_entry_element
    find(".ui-resource[data-type='media-entry']", match: :first)
  end
end
