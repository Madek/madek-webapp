require_relative './_shared'

feature 'manage custom urls' do

  scenario 'check errors for media entry' do
    media_entry = create_user_and_media_entry
    scenario_check_errors(media_entry)
  end

  scenario 'check errors for collection' do
    collection = create_user_and_collection
    scenario_check_errors(collection)
  end

end
