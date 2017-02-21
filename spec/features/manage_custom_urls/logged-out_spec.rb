require_relative './_shared'

feature 'manage custom urls' do

  scenario 'check action button not shown when logged out for media entry' do
    prepare_user
    media_entry = create_media_entry('Media Entry')
    visit_resource(media_entry)
    check_disabled_action_button
  end

  scenario 'check action button not shown when logged out for collection' do
    prepare_user
    collection = create_collection('Collection')
    visit_resource(collection)
    check_disabled_action_button
  end

end
