require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::Shared::MediaResources::MediaResources do
  it_can_be 'dumped' do
    let(:presenter) do
      described_class.new(FactoryGirl.create(:user),
                          media_entries: MediaEntry.unscoped,
                          collections: Collection.unscoped,
                          filter_sets: FilterSet.unscoped)
    end
  end

  context 'visibility' do
    it 'public permission' do
      user = FactoryGirl.create(:user)

      media_entry_1 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: true)
      media_entry_2 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      collection_1 = \
        FactoryGirl.create(:collection,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: true)
      collection_2 = \
        FactoryGirl.create(:collection,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      filter_set_1 = \
        FactoryGirl.create(:filter_set,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: true)
      filter_set_2 = \
        FactoryGirl.create(:filter_set,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      p = described_class.new(user,
                              media_entries: \
                                MediaEntry.where(id: [media_entry_1.id,
                                                      media_entry_2.id]),
                              collections: \
                                Collection.where(id: [collection_1.id,
                                                      collection_2.id]),
                              filter_sets: \
                                FilterSet.where(id: [filter_set_1.id,
                                                     filter_set_2.id]))

      expect(p.media_entries.size).to be == 1
      expect(p.media_entries.map(&:uuid)).to include media_entry_1.id
      expect(p.collections.size).to be == 1
      expect(p.collections.map(&:uuid)).to include collection_1.id
      expect(p.filter_sets.size).to be == 1
      expect(p.filter_sets.map(&:uuid)).to include filter_set_1.id
    end

    it 'user permission' do
      user = FactoryGirl.create(:user)

      media_entry_1 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      collection_1 = \
        FactoryGirl.create(:collection,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)
      collection_2 = \
        FactoryGirl.create(:collection,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      filter_set_1 = \
        FactoryGirl.create(:filter_set,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)
      filter_set_2 = \
        FactoryGirl.create(:filter_set,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      FactoryGirl.create(:media_entry_user_permission,
                         media_entry: media_entry_1,
                         user: user,
                         get_metadata_and_previews: true)
      FactoryGirl.create(:collection_user_permission,
                         collection: collection_1,
                         user: user,
                         get_metadata_and_previews: true)
      FactoryGirl.create(:filter_set_user_permission,
                         filter_set: filter_set_1,
                         user: user,
                         get_metadata_and_previews: true)

      p = described_class.new(user,
                              media_entries: \
                                MediaEntry.where(id: [media_entry_1.id,
                                                      media_entry_2.id]),
                              collections: \
                                Collection.where(id: [collection_1.id,
                                                      collection_2.id]),
                              filter_sets: \
                                FilterSet.where(id: [filter_set_1.id,
                                                     filter_set_2.id]))

      expect(p.media_entries.size).to be == 1
      expect(p.media_entries.map(&:uuid)).to include media_entry_1.id
      expect(p.collections.size).to be == 1
      expect(p.collections.map(&:uuid)).to include collection_1.id
      expect(p.filter_sets.size).to be == 1
      expect(p.filter_sets.map(&:uuid)).to include filter_set_1.id
    end

    it 'group permission' do
      user = FactoryGirl.create(:user)

      media_entry_1 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      collection_1 = \
        FactoryGirl.create(:collection,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)
      collection_2 = \
        FactoryGirl.create(:collection,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      filter_set_1 = \
        FactoryGirl.create(:filter_set,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)
      filter_set_2 = \
        FactoryGirl.create(:filter_set,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      group = FactoryGirl.create(:group)
      user.groups << group

      FactoryGirl.create(:media_entry_user_permission,
                         media_entry: media_entry_1,
                         user: user,
                         get_metadata_and_previews: true)
      FactoryGirl.create(:collection_user_permission,
                         collection: collection_1,
                         user: user,
                         get_metadata_and_previews: true)
      FactoryGirl.create(:filter_set_user_permission,
                         filter_set: filter_set_1,
                         user: user,
                         get_metadata_and_previews: true)

      p = described_class.new(user,
                              media_entries: \
                                MediaEntry.where(id: [media_entry_1.id,
                                                      media_entry_2.id]),
                              collections: \
                                Collection.where(id: [collection_1.id,
                                                      collection_2.id]),
                              filter_sets: \
                                FilterSet.where(id: [filter_set_1.id,
                                                     filter_set_2.id]))

      expect(p.media_entries.size).to be == 1
      expect(p.media_entries.map(&:uuid)).to include media_entry_1.id
      expect(p.collections.size).to be == 1
      expect(p.collections.map(&:uuid)).to include collection_1.id
      expect(p.filter_sets.size).to be == 1
      expect(p.filter_sets.map(&:uuid)).to include filter_set_1.id
    end

    it 'responsible user' do
      user = FactoryGirl.create(:user)

      media_entry_1 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: user,
                           get_metadata_and_previews: false)
      media_entry_2 = \
        FactoryGirl.create(:media_entry,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      collection_1 = \
        FactoryGirl.create(:collection,
                           responsible_user: user,
                           get_metadata_and_previews: false)
      collection_2 = \
        FactoryGirl.create(:collection,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      filter_set_1 = \
        FactoryGirl.create(:filter_set,
                           responsible_user: user,
                           get_metadata_and_previews: false)
      filter_set_2 = \
        FactoryGirl.create(:filter_set,
                           responsible_user: FactoryGirl.create(:user),
                           get_metadata_and_previews: false)

      p = described_class.new(user,
                              media_entries: \
                                MediaEntry.where(id: [media_entry_1.id,
                                                      media_entry_2.id]),
                              collections: \
                                Collection.where(id: [collection_1.id,
                                                      collection_2.id]),
                              filter_sets: \
                                FilterSet.where(id: [filter_set_1.id,
                                                     filter_set_2.id]))

      expect(p.media_entries.size).to be == 1
      expect(p.media_entries.map(&:uuid)).to include media_entry_1.id
      expect(p.collections.size).to be == 1
      expect(p.collections.map(&:uuid)).to include collection_1.id
      expect(p.filter_sets.size).to be == 1
      expect(p.filter_sets.map(&:uuid)).to include filter_set_1.id
    end
  end
end
