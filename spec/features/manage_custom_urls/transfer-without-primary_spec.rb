require_relative './_shared'

feature 'manage custom urls' do

  scenario 'transfer to media entry without primary' do
    prepare_user
    login
    media_entry_1 = create_media_entry('Media Entry 1')
    media_entry_2 = create_media_entry('Media Entry 2')
    scenario_transfer_to_resource_without_primary(media_entry_1, media_entry_2)
  end

  scenario 'transfer to collection without primary' do
    prepare_user
    login
    collection_1 = create_collection('Collection 1')
    collection_2 = create_collection('Collection 2')
    scenario_transfer_to_resource_without_primary(collection_1, collection_2)
  end

end
