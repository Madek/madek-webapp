require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MetaData' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user
    meta_key = FactoryGirl.create :meta_key_text, id: 'media_content:test'
    @meta_datum = FactoryGirl.create :meta_datum_text,
                                     meta_key: meta_key,
                                     media_entry: @media_entry

  end

  context 'update MetaDatum::Text NOJS' do

    scenario 'single update' do
      new_text = Faker::Lorem.words.join(' ')

      visit media_entry_path(@media_entry)
      click_on @meta_datum.meta_key.id.split(':').last.humanize

      click_on 'Edit'

      within("form[action='#{meta_datum_path(@meta_datum)}']") do
        find('input[type="text"]').set(new_text)
        submit_form
      end

      expect(find('.app-body')).to have_content new_text
    end
  end

  context 'inline edit MetaDatum::Text HASJS', browser: :firefox do

    scenario 'single update' do
      new_text = Faker::Lorem.words.join(' ')

      visit media_entry_path(@media_entry)

      within("[data-meta-datum-url=\"#{meta_datum_path(@meta_datum)}\"]") do
        find('a').click
        find('input').set(new_text)
        submit_form
        # wait for xhr to finish:
        find('[data-meta-datum-persisted]', text: new_text)
      end

      expect(@meta_datum.reload.string).to eq new_text
    end
  end
end
