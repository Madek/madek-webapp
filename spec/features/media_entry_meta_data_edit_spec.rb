require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaEntry MetaData' do
  background do
    # TODO: disable personas, use factories User, Entry, MetaKeys, MetaData
    @user = User.find_by(login: 'normin')
    @entry = MediaEntry.find('fc66605c-64c9-4d8b-96fb-5210bc4addd0')

    # These cases are tested:
    # (MD="A MetaDatum for this MetaKey on this MediaResource")

    # 1. a. MD::Text exists, value is present: update MD
    @mkey_title = MetaKey.find('media_content:title')
    @new_title = Faker::Lorem.word

    # 1. b. MD::People exists, value is present: update MD
    @mkey_authors = MetaKey.find('media_content:author')
    expect(datum(@mkey_authors).people.length).to eq 1
    @the_coauthor = FactoryGirl.create(:person)

    # 2. MD exists, value is empty: delete MD
    @mkey_description = MetaKey.find('media_content:description')
    FactoryGirl.create(:meta_datum_text,
                       meta_key: @mkey_description,
                       string: 'X',
                       media_entry: @entry)

    # 3. MD does not exist, value is present: create MD
    @mkey_creators = MetaKey.find('media_object:creator')
    datum(@mkey_creators).delete
    @the_creator = FactoryGirl.create(:person)

    # 4. MD does not exist, value is empty: ignore/skip
    @mkey_date = MetaKey.find('media_content:portrayed_object_dates')
    datum(@mkey_date).delete if datum(@mkey_date)

    @entry.reload
    sign_in_as @user.login
  end

  scenario 'JS: model integration', browser: :firefox do
    config = {
      entry: media_entry_path(@entry),
      meta_key_id: 'media_content:title',
      values: [@new_title]
    }

    # changes the configured key to value and saves to server:
    # response is the serialized model
    response = js_integration_test 'MediaEntryMetaData', config
    expect(response['body']['uuid']).to eq @entry.id
    expect(response['body']['type']).to eq 'MediaEntry'

    # expect the change to reflected in db
    expect(datum(config[:meta_key_id]).string).to eq @new_title
  end

  scenario 'simple edit NOJS', browser: :firefox_nojs do
    visit media_entry_path(@entry)

    find('.ui-body-title-actions')
      .find('.icon-pen')
      .click

    expect(current_path).to eq edit_meta_data_media_entry_path(@entry)

    within('form[name="resource_meta_data"]') do
      # 1A. (change title)
      find_meta_key_form(@mkey_title)
        .find('input')
        .set(@new_title)
      # 1B. (add author)
      find_meta_key_form(@mkey_authors)
        .find('.form-item-add input')
        .set(@the_coauthor.id)
      # 2. (remove description)
      find_meta_key_form(@mkey_description)
        .find('input')
        .set('')
      # 3. (set new creator)
      find_meta_key_form(@mkey_creators)
        .find('.form-item-add input')
        .set(@the_creator.id)
      # 4. (nothing to do)
      submit_form
    end

    expect(current_path).to eq media_entry_path(@entry)
    @entry.reload

    expect(datum(@mkey_title).string).to eq @new_title
    expect(datum(@mkey_authors).try(:people)).to include(@the_coauthor)
    expect(datum(@mkey_description)).to eq nil
    expect(datum(@mkey_creators).try(:people)).to eq([@the_creator])
    expect(datum(@mkey_date)).to eq nil
  end

end

def datum(meta_key)
  @entry.reload.meta_data.find_by(meta_key: meta_key)
end

def find_vocabulary_form(name)
  find('h3', text: name).find(:xpath, '../..')
end

def find_meta_key_form(meta_key)
  find_vocabulary_form(meta_key.vocabulary.label)
    .find('.form-label *', text: meta_key.label).find(:xpath, '../..')
end
