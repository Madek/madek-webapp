require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

# todo something is odd with these tests; it seems they somehow 
# circumvent the db setup (restoring seeds e.g.)

describe Presenters::MediaEntries::MediaEntryIndex do
#  it_can_be 'dumped' do
#    media_entry = FactoryBot.create(:media_entry_with_image_media_file)
#
#    meta_key = MetaKey.find_by_id('madek_core:title')
#
#    FactoryBot.create :meta_datum_text,
#                       meta_key: meta_key,
#                       media_entry: media_entry
#
#    let(:presenter) \
#      { described_class.new(media_entry, media_entry.responsible_user) }
#  end
#
#  it_responds_to 'privacy_status' do
#    let(:resource_type) { :media_entry }
#  end
#
#  context 'image_url' do
#    it_responds_to 'image_url', 'with preview image' do
#      media_entry = FactoryBot.create(:media_entry_with_image_media_file)
#      let(:resource) { media_entry }
#      let(:media_entry) { media_entry }
#    end
#
#    it_responds_to 'image_url', 'with no image' do
#      media_entry = FactoryBot.create(:media_entry_with_audio_media_file)
#      let(:resource) { media_entry }
#      let(:media_entry) { media_entry }
#    end
#  end
end
