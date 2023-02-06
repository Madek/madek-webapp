require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'
require Rails.root.join 'spec',
                        'presenters',
                        'shared',
                        'media_resources',
                        'select_media_resources'

describe Presenters::Collections::ChildMediaResources do
  include_context 'select media resources'

  before :example do
    @user = FactoryBot.create(:user)
  end

  it_can_be 'dumped' do
    let(:presenter) do
      described_class.new(
        MediaResource.limit(36).viewable_by_user_or_public(@user),
        @user,
        list_conf: {})
    end
  end

  context 'visibility' do
    it 'public permission' do
      media_entry_1 = \
        FactoryBot.create(:media_entry,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: true)
      media_entry_2 = \
        FactoryBot.create(:media_entry,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)

      collection_1 = \
        FactoryBot.create(:collection,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: true)
      collection_2 = \
        FactoryBot.create(:collection,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)

      p = described_class.new(
        MediaResource.where(id: [media_entry_1.id,
                                 media_entry_2.id,
                                 collection_1.id,
                                 collection_2.id])
          .viewable_by_user_or_public(@user),
        @user,
        list_conf: {})

      expect(select_media_entries(p.resources).length).to be == 1
      expect(select_media_entries(p.resources).map(&:uuid))
        .to include media_entry_1.id
      expect(select_collections(p.resources).length).to be == 1
      expect(select_collections(p.resources).map(&:uuid))
        .to include collection_1.id
    end

    it 'user permission' do
      media_entry_1 = \
        FactoryBot.create(:media_entry,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryBot.create(:media_entry,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)

      collection_1 = \
        FactoryBot.create(:collection,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)
      collection_2 = \
        FactoryBot.create(:collection,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)

      FactoryBot.create(:media_entry_user_permission,
                         media_entry: media_entry_1,
                         user: @user,
                         get_metadata_and_previews: true)
      FactoryBot.create(:collection_user_permission,
                         collection: collection_1,
                         user: @user,
                         get_metadata_and_previews: true)

      p = described_class.new(
        MediaResource.where(id: [media_entry_1.id,
                                 media_entry_2.id,
                                 collection_1.id,
                                 collection_2.id])
          .viewable_by_user_or_public(@user),
        @user,
        list_conf: {})

      expect(select_media_entries(p.resources).length).to be == 1
      expect(select_media_entries(p.resources).map(&:uuid))
        .to include media_entry_1.id
      expect(select_collections(p.resources).length).to be == 1
      expect(select_collections(p.resources).map(&:uuid))
        .to include collection_1.id
    end

    it 'group permission' do
      media_entry_1 = \
        FactoryBot.create(:media_entry,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryBot.create(:media_entry,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)

      collection_1 = \
        FactoryBot.create(:collection,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)
      collection_2 = \
        FactoryBot.create(:collection,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)

      group = FactoryBot.create(:group)
      @user.groups << group

      FactoryBot.create(:media_entry_user_permission,
                         media_entry: media_entry_1,
                         user: @user,
                         get_metadata_and_previews: true)
      FactoryBot.create(:collection_user_permission,
                         collection: collection_1,
                         user: @user,
                         get_metadata_and_previews: true)

      p = described_class.new(
        MediaResource.where(id: [media_entry_1.id,
                                 media_entry_2.id,
                                 collection_1.id,
                                 collection_2.id])
          .viewable_by_user_or_public(@user),
        @user,
        list_conf: {})

      expect(select_media_entries(p.resources).length).to be == 1
      expect(select_media_entries(p.resources).map(&:uuid))
        .to include media_entry_1.id
      expect(select_collections(p.resources).length).to be == 1
      expect(select_collections(p.resources).map(&:uuid))
        .to include collection_1.id
    end

    it 'responsible user' do
      media_entry_1 = \
        FactoryBot.create(:media_entry,
                           responsible_user: @user,
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryBot.create(:media_entry,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)

      collection_1 = \
        FactoryBot.create(:collection,
                           responsible_user: @user,
                           get_metadata_and_previews: false)
      collection_2 = \
        FactoryBot.create(:collection,
                           responsible_user: FactoryBot.create(:user),
                           get_metadata_and_previews: false)

      p = described_class.new(
        MediaResource.where(id: [media_entry_1.id,
                                 media_entry_2.id,
                                 collection_1.id,
                                 collection_2.id])
          .viewable_by_user_or_public(@user),
        @user,
        list_conf: {})

      expect(select_media_entries(p.resources).length).to be == 1
      expect(select_media_entries(p.resources).map(&:uuid))
        .to include media_entry_1.id
      expect(select_collections(p.resources).length).to be == 1
      expect(select_collections(p.resources).map(&:uuid))
        .to include collection_1.id
    end
  end
end
