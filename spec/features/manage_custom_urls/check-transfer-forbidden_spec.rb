require_relative './_shared'

feature 'manage custom urls' do

  scenario 'check transfer not allowed for media entry' do
    prepare_user
    login
    media_entry_1 = create_media_entry('Media Entry 1')
    media_entry_2 = create_media_entry('Media Entry 2')
    scenario_transfer_not_allowed(media_entry_1, media_entry_2)
  end

  scenario 'check transfer not allowed for collection' do
    prepare_user
    login
    collection_1 = create_collection('Collection 1')
    collection_2 = create_collection('Collection 2')
    scenario_transfer_not_allowed(collection_1, collection_2)
  end

  scenario 'check cross transfer not allowed' do
    prepare_user
    login
    media_entry = create_media_entry('Media Entry')
    collection = create_collection('Collection')
    scenario_check_cross_transfer_not_allowed(media_entry, collection)
  end

end
