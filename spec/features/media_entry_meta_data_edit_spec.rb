require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

doc = <<-DOC
Action: Updating

"Create", "Add Value", "Modify Value" and "Delete" Metadata

Tested variations :
1. a. MD::Text exists, value is present: update MD
1. b. MD::People exists, value is present: update MD
2. MD exists, value is empty: delete MD
3. MD does not exist, value is present: create MD
4. MD does not exist, value is empty: ignore/skip

(MD="A MetaDatum for this MetaKey on this Resource")
DOC

feature 'Resource: MediaEntry' do
describe 'Concern: MetaData' do

  describe doc do

    background do
      # TODO: use factories
      @user = User.find_by(login: 'normin')
      @entry = MediaEntry.find('fc66605c-64c9-4d8b-96fb-5210bc4addd0')

      # 1. a.
      @mkey_title = MetaKey.find('madek_core:title')
      @new_title = Faker::Lorem.word

      # 1. b.
      @mkey_authors = MetaKey.find('madek_core:authors')
      expect(datum(@mkey_authors).people.length).to eq 1
      @the_coauthor = FactoryGirl.create(:person)

      # 2.
      @mkey_description = MetaKey.find('madek_core:description')
      FactoryGirl.create(:meta_datum_text,
                         meta_key: @mkey_description,
                         string: 'X',
                         media_entry: @entry)

      # 3.
      @mkey_creators = MetaKey.find('media_object:creator')
      datum(@mkey_creators).delete
      @the_creator = FactoryGirl.create(:person)

      # 4.
      @mkey_date = MetaKey.find('madek_core:portrayed_object_date')
      datum(@mkey_date).delete if datum(@mkey_date)

      @entry.reload
      sign_in_as @user.login
    end

    scenario 'update via Javascript Models (unit test)', browser: :firefox do
      config = {
        entry: media_entry_path(@entry),
        meta_key_id: 'madek_core:title',
        values: [@new_title]
      }

      # changes the configured key to value and saves to server:
      # response is a forward url or errors
      response = js_integration_test 'MediaEntryMetaData', config
      expect(response['body']['forward_url']).to eq media_entry_path(@entry)

      # expect the change to reflected in db
      expect(datum(config[:meta_key_id]).string).to eq @new_title
    end

    it 'update via Edit-Form (Javascript disabled)', browser: :firefox_nojs do
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
    .find('.form-label *:first-child', text: meta_key.label).find(:xpath, '../..')
end
