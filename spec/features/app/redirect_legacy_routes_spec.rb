require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'App: Redirect legacy routes (v2—v3)' do

  example 'redirect `/media_resources/${uuid}` to Entry' do
    entry = create(:media_entry, get_metadata_and_previews: true)
    visit "/media_resources/#{entry.id}"
    expect(current_path).to eq media_entry_path(entry)
  end

  example 'redirect `/media_resources/${uuid}` to Collection' do
    collection = create(:collection, get_metadata_and_previews: true)
    visit "/media_resources/#{collection.id}"
    expect(current_path).to eq collection_path(collection)
  end

end
