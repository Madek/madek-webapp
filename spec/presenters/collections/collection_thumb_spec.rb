require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

# todo something is odd with these tests; it seems they somehow 
# circumvent the db setup (restoring seeds e.g.)

describe Presenters::Collections::CollectionIndex do
#
#  before :each do
#    AppSetting.find_or_create_by(id: 0)
#  end
#
#  it_can_be 'dumped' do
#    collection = FactoryBot.create(:collection)
#
#    meta_key = MetaKey.find_by_id('madek_core:title')
#
#    FactoryBot.create :meta_datum_text,
#                       meta_key: meta_key,
#                       collection: collection
#
#    let(:presenter) \
#      { described_class.new(collection, collection.responsible_user) }
#  end
#
#  it_responds_to 'privacy_status' do
#    let(:resource_type) { :collection }
#  end
#
#  context 'image url' do
#
#    it_responds_to 'image_url', 'with preview image' do
#      collection = FactoryBot.create(:collection)
#      user = collection.responsible_user
#      media_entry = FactoryBot.create(
#        :media_entry_with_image_media_file,
#        creator: user, responsible_user: user)
#      collection.media_entries << media_entry
#
#      let(:resource) { collection }
#      let(:media_entry) { media_entry }
#    end
#
#    it_responds_to 'image_url', 'with no image' do
#      collection = FactoryBot.create(:collection)
#      user = collection.responsible_user
#      media_entry = FactoryBot.create(
#        :media_entry_with_audio_media_file,
#        creator: user, responsible_user: user)
#      collection.media_entries << media_entry
#
#      let(:resource) { collection }
#      let(:media_entry) { media_entry }
#    end
#  end
end
