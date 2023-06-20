require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaEntries::MediaEntryIndex do
  before :each do
    AppSetting.find_or_create_by(id: 0)
  end

  it_can_be 'dumped' do
    ##############################################
    # ...because before hooks don't get executed !
    truncate_tables
    restore_seeds
    ##############################################

    media_entry = FactoryBot.create(:media_entry_with_image_media_file)

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
    it 'responds to image_url with preview image' do
      media_entry = FactoryBot.create(:media_entry_with_image_media_file)

      presenter = described_class.new(media_entry, media_entry.responsible_user)

      expect(presenter.image_url).to be == \
        Rails.application.routes.url_helpers
        .preview_path(media_entry.media_file.preview(:medium)) + '.jpg'
    end

    it 'responds to image_url with no image' do
      media_entry = FactoryBot.create(:media_entry_with_audio_media_file)
      presenter = described_class.new(media_entry, media_entry.responsible_user)
      expect(presenter.image_url).to be_nil
    end
  end
end
