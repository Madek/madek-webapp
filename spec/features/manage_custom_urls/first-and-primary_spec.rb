require_relative './_shared'

feature 'manage custom urls' do

  scenario 'check creating first custom url for media entry' do
    media_entry = create_user_and_media_entry
    scenario_creating_first(media_entry)
  end

  scenario 'check creating first custom url for collection' do
    collection = create_user_and_collection
    scenario_creating_first(collection)
  end

  scenario 'check set primary custom url for media entry' do
    media_entry = create_user_and_media_entry
    scenario_set_primary(media_entry)
  end

  scenario 'check set primary custom url for media entry' do
    collection = create_user_and_collection
    scenario_set_primary(collection)
  end

end
