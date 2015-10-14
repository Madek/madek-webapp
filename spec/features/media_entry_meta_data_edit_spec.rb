require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaEntry MetaData' do
  background do
    # TODO: disable personas, use factories User, Entry, MetaKeys, MetaData
    @user = User.find_by(login: 'normin')
    @entry = MediaEntry.find('fc66605c-64c9-4d8b-96fb-5210bc4addd0')
    @new_title = Faker::Lorem.word
    @another_person = FactoryGirl.create(:person)
    sign_in_as @user.login
  end

  scenario 'wip JS model', browser: :firefox do
    pending 'models not used atm'

    config = {
      entry: media_entry_path(@entry),
      meta_key_id: 'media_content:title',
      values: [@new_title]
    }

    js_integration_test 'MediaEntryMetaData', config

    expect(datum(config[:meta_key_id]).string).to eq @new_title
  end

  scenario 'simple edit NOJS', browser: :firefox do
    visit media_entry_path(@entry)

    find('.ui-body-title-actions')
      .find('.icon-pen')
      .click

    expect(current_path).to eq edit_meta_data_media_entry_path(@entry)

    reload_without_js

    within('form[name="resource_meta_data"]') do
      find_meta_key_form('Werk', 'Titel des Werks')
        .find('input')
        .set(@new_title)

      find_meta_key_form('Werk', 'Autor/in')
        .find('.form-item-add input')
        .set(@another_person.id)

      submit_form
    end

    expect(current_path).to eq media_entry_path(@entry)
    @entry.reload

    expect(datum('media_content:author').people).to include(@another_person)
    expect(datum('media_content:title').string).to eq @new_title
  end

end

def datum(meta_key_id)
  @entry.meta_data.find_by(meta_key: meta_key_id)
end

def find_vocabulary_form(name)
  find('h3', text: name).find(:xpath, '../..')
end

def find_meta_key_form(vocabulary, name)
  find_vocabulary_form(vocabulary)
    .find('.form-label *', text: name).find(:xpath, '../..')
end
