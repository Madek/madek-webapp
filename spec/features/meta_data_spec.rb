require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MetaData NOJS', browser: :firefox do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user
  end

  scenario 'update MetaDatum::Text' do

    meta_key = FactoryGirl.create :meta_key_text, id: 'media_content:test'
    meta_datum = FactoryGirl.create :meta_datum_text,
                                    meta_key: meta_key,
                                    media_entry: @media_entry
    new_text = Faker::Lorem.words.join(' ')

    visit media_entry_path(@media_entry)
    click_on meta_datum.meta_key.id.split(':').last.humanize
    click_on 'Edit'

    fill_in '_value_content_', with: new_text
    click_on 'Save'

    expect(find('.app-body'))
      .to have_content new_text
  end

end
