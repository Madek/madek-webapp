require_relative './_shared'

feature 'manage custom urls' do

  scenario 'check transfer for media entry' do
    prepare_user
    login
    media_entry_1 = create_media_entry('Media Entry 1')
    media_entry_2 = create_media_entry('Media Entry 2')
    scenario_check_transfer(media_entry_1, media_entry_2)
  end

  scenario 'check transfer for collection' do
    prepare_user
    login
    collection_1 = create_collection('Collection 1')
    collection_2 = create_collection('Collection 2')
    scenario_check_transfer(collection_1, collection_2)
  end

end
