require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaEntries::MediaEntryIndex do
  it_can_be 'dumped' do
    media_entry = FactoryBot.create(:media_entry_with_image_media_file)

    unless MetaKey.find_by_id('madek_core:title')
      with_disabled_triggers do
        # TODO: remove as soon as the madek_core meta data is part of the test db
        FactoryBot.create :meta_key_core_title
      end
    end

    meta_key = MetaKey.find_by_id('madek_core:title')

    FactoryBot.create :meta_datum_text,
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
      media_entry = FactoryBot.create(:media_entry_with_image_media_file)
      let(:resource) { media_entry }
      let(:media_entry) { media_entry }
    end

    it_responds_to 'image_url', 'with no image' do
      media_entry = FactoryBot.create(:media_entry_with_audio_media_file)
      let(:resource) { media_entry }
      let(:media_entry) { media_entry }
    end
  end
end
