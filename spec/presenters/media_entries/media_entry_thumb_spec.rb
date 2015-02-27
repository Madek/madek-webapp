require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaEntries::MediaEntryThumb do
  it_can_be 'dumped' do
    media_entry = FactoryGirl.create(:media_entry)

    unless MetaKey.find_by_id('madek:core:title')
      with_disabled_triggers do
        # TODO: remove as soon as the madek:core meta data is part of the test db
        MetaKey.create id: 'madek:core:title',
                       meta_datum_object_type: 'MetaDatum::Text'
      end
    end

    meta_key = MetaKey.find_by_id('madek:core:title')

    FactoryGirl.create :meta_datum_text,
                       meta_key: meta_key,
                       media_entry: media_entry

    let(:presenter) \
      { described_class.new(media_entry, media_entry.responsible_user) }
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :media_entry }
  end

  context 'image_url' do
    it_responds_to 'image_url', 'with preview image' do
      media_entry = FactoryGirl.create(:media_entry_with_image_media_file)
      let(:resource) { media_entry }
      let(:media_entry) { media_entry }
    end

    it_responds_to 'image_url', 'with generic image' do
      media_entry = FactoryGirl.create(:media_entry_with_audio_media_file)
      let(:resource) { media_entry }
      let(:media_entry) { media_entry }
    end
  end
end
