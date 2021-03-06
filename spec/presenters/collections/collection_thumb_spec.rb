require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::Collections::CollectionIndex do

  it_can_be 'dumped' do
    collection = FactoryGirl.create(:collection)

    unless MetaKey.find_by_id('madek_core:title')
      with_disabled_triggers do
        # TODO: remove as soon as the madek_core meta data is part of the test db
        MetaKey.find_by(id: 'madek_core:title') \
          || FactoryGirl.create(:meta_key_core_title)
      end
    end

    meta_key = MetaKey.find_by_id('madek_core:title')

    FactoryGirl.create :meta_datum_text,
                       meta_key: meta_key,
                       collection: collection

    let(:presenter) \
      { described_class.new(collection, collection.responsible_user) }
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :collection }
  end

  context 'image url' do
    it_responds_to 'image_url', 'with preview image' do
      collection = FactoryGirl.create(:collection)
      user = collection.responsible_user
      media_entry = FactoryGirl.create(
        :media_entry_with_image_media_file,
        creator: user, responsible_user: user)
      collection.media_entries << media_entry

      let(:resource) { collection }
      let(:media_entry) { media_entry }
    end

    it_responds_to 'image_url', 'with no image' do
      collection = FactoryGirl.create(:collection)
      user = collection.responsible_user
      media_entry = FactoryGirl.create(
        :media_entry_with_audio_media_file,
        creator: user, responsible_user: user)
      collection.media_entries << media_entry

      let(:resource) { collection }
      let(:media_entry) { media_entry }
    end
  end
end
