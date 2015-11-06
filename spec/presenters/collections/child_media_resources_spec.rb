require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'
require Rails.root.join 'spec',
                        'presenters',
                        'shared',
                        'media_resources',
                        'select_media_resources'

describe Presenters::Collections::ChildMediaResources do
  include_context 'select media resources'

  it_can_be 'dumped' do
    let(:presenter) do
      described_class.new(
        MediaResource.limit(36), FactoryGirl.create(:user), list_conf: {})
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

      p = described_class.new(MediaResource.where(id: [media_entry_1.id,
                                                       media_entry_2.id,
                                                       collection_1.id,
                                                       collection_2.id,
                                                       filter_set_1.id,
                                                       filter_set_2.id]),
                              user,
                              list_conf: {})

      expect(select_media_entries(p.resources).length).to be == 1
      expect(select_media_entries(p.resources).map(&:uuid))
        .to include media_entry_1.id
      expect(select_collections(p.resources).length).to be == 1
      expect(select_collections(p.resources).map(&:uuid))
        .to include collection_1.id
      expect(select_filter_sets(p.resources).length).to be == 1
      expect(select_filter_sets(p.resources).map(&:uuid))
        .to include filter_set_1.id
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

      p = described_class.new(MediaResource.where(id: [media_entry_1.id,
                                                       media_entry_2.id,
                                                       collection_1.id,
                                                       collection_2.id,
                                                       filter_set_1.id,
                                                       filter_set_2.id]),
                              user,
                              list_conf: {})

      expect(select_media_entries(p.resources).length).to be == 1
      expect(select_media_entries(p.resources).map(&:uuid))
        .to include media_entry_1.id
      expect(select_collections(p.resources).length).to be == 1
      expect(select_collections(p.resources).map(&:uuid))
        .to include collection_1.id
      expect(select_filter_sets(p.resources).length).to be == 1
      expect(select_filter_sets(p.resources).map(&:uuid))
        .to include filter_set_1.id
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

      p = described_class.new(MediaResource.where(id: [media_entry_1.id,
                                                       media_entry_2.id,
                                                       collection_1.id,
                                                       collection_2.id,
                                                       filter_set_1.id,
                                                       filter_set_2.id]),
                              user,
                              list_conf: {})

      expect(select_media_entries(p.resources).length).to be == 1
      expect(select_media_entries(p.resources).map(&:uuid))
        .to include media_entry_1.id
      expect(select_collections(p.resources).length).to be == 1
      expect(select_collections(p.resources).map(&:uuid))
        .to include collection_1.id
      expect(select_filter_sets(p.resources).length).to be == 1
      expect(select_filter_sets(p.resources).map(&:uuid))
        .to include filter_set_1.id
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

      p = described_class.new(MediaResource.where(id: [media_entry_1.id,
                                                       media_entry_2.id,
                                                       collection_1.id,
                                                       collection_2.id,
                                                       filter_set_1.id,
                                                       filter_set_2.id]),
                              user,
                              list_conf: {})

      expect(select_media_entries(p.resources).length).to be == 1
      expect(select_media_entries(p.resources).map(&:uuid))
        .to include media_entry_1.id
      expect(select_collections(p.resources).length).to be == 1
      expect(select_collections(p.resources).map(&:uuid))
        .to include collection_1.id
      expect(select_filter_sets(p.resources).length).to be == 1
      expect(select_filter_sets(p.resources).map(&:uuid))
        .to include filter_set_1.id
    end
  end
end
