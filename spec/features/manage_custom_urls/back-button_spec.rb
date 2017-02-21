require_relative './_shared'

feature 'manage custom urls' do

  scenario 'check action and back button working for media entry' do
    media_entry = create_user_and_media_entry
    scenario_action_and_back_button(media_entry)
  end

  scenario 'check action and back button working for collection' do
    collection = create_user_and_collection
    scenario_action_and_back_button(collection)
  end

end
