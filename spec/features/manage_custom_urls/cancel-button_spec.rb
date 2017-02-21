require_relative './_shared'

feature 'manage custom urls' do

  scenario 'check cancel button for media entry' do
    media_entry = create_user_and_media_entry
    scenario_cancel_button(media_entry)
  end

  scenario 'check cancel button for collection' do
    collection = create_user_and_collection
    scenario_cancel_button(collection)
  end

end
