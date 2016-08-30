require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'App: Redirect by UUID, e.g. `/id/{id-of-entry}` => `/entries/{id}`' do

  example 'redirect by UUID of MediaEntry' do
    entry = create(:media_entry, get_metadata_and_previews: true)
    visit "/id/#{entry.id}"
    expect(current_path).to eq media_entry_path(entry)
  end

  example 'redirect by UUID of Collection' do
    collection = create(:collection, get_metadata_and_previews: true)
    visit "/id/#{collection.id}"
    expect(current_path).to eq collection_path(collection)
  end

end
