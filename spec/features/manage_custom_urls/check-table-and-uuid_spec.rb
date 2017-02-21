require_relative './_shared'

feature 'manage custom urls' do

  scenario 'check table content for media entry' do
    media_entry = create_user_and_media_entry
    scenario_table_content(media_entry)
  end

  scenario 'check table content for collection' do
    collection = create_user_and_collection
    scenario_table_content(collection)
  end

  scenario 'set uuid as primary for media entry' do
    media_entry = create_user_and_media_entry
    scenario_set_uuid_as_primary(media_entry)
  end

  scenario 'set uuid as primary for collection' do
    collection = create_user_and_collection
    scenario_set_uuid_as_primary(collection)
  end

end
