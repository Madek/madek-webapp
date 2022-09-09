require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'
require Rails.root.join 'spec',
                        'presenters',
                        'shared',
                        'media_resources',
                        'relations_setup'
require Rails.root.join 'spec',
                        'presenters',
                        'shared',
                        'media_resources',
                        'select_media_resources'

# NOTE: this only contains tests regarding the child_media_resources
#       (extracted from relations)

describe Presenters::Collections::CollectionShow do
  include_context 'relations'
  include_context 'select media resources'

  def user_scopes_for_collection(collection)
    { highlighted_media_entries: \
        collection.highlighted_media_entries.viewable_by_user_or_public(@user),
      highlighted_collections: \
          collection.highlighted_collections.viewable_by_user_or_public(@user),
      child_media_resources: \
        collection.child_media_resources.viewable_by_user_or_public(@user),
      parent_collections: \
        collection.parent_collections.viewable_by_user_or_public(@user),
      sibling_collections: \
        collection.sibling_collections.viewable_by_user_or_public(@user),
      child_collections: \
        collection.collections.viewable_by_user_or_public(@user) }
  end

  context 'dumps' do
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(@collection_A,
                            @user,
                            user_scopes_for_collection(@collection_A),
                            list_conf: {})
      end
    end
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(@collection_B,
                            @user,
                            user_scopes_for_collection(@collection_B),
                            list_conf: {})
      end
    end
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(@collection_C,
                            @user,
                            user_scopes_for_collection(@collection_C),
                            list_conf: {})
      end
    end
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(@collection_D,
                            @user,
                            user_scopes_for_collection(@collection_D),
                            list_conf: {})
      end
    end
  end

  context 'relations' do

    it 'context collection_A' do
      @p = described_class.new(@collection_A,
                               @user,
                               user_scopes_for_collection(@collection_A),
                               list_conf: {})

      ########### CHILDREN ######################################
      expect(select_collections(@p.child_media_resources.resources).length)
        .to be 2
      expect(select_collections(@p.child_media_resources.resources).map(&:uuid))
        .to include @collection_B.id
      expect(select_collections(@p.child_media_resources.resources).map(&:uuid))
        .to include @collection_C.id

      expect(select_media_entries(@p.child_media_resources.resources).length)
        .to be 1
      expect(select_media_entries(@p.child_media_resources.resources).map(&:uuid))
        .to include @media_entry_1.id

    end

    it 'context collection_B' do
      @p = described_class.new(@collection_B,
                               @user,
                               user_scopes_for_collection(@collection_B),
                               list_conf: {})

      ########### CHILDREN ######################################
      expect(select_collections(@p.child_media_resources.resources).length)
        .to be 0

      expect(select_media_entries(@p.child_media_resources.resources).length)
        .to be 3
      expect(select_media_entries(@p.child_media_resources.resources).map(&:uuid))
        .to include @media_entry_1.id
      expect(select_media_entries(@p.child_media_resources.resources).map(&:uuid))
        .to include @media_entry_2.id
      expect(select_media_entries(@p.child_media_resources.resources).map(&:uuid))
        .to include @media_entry_3.id

    end

    it 'context collection_C' do
      @p = described_class.new(@collection_C,
                               @user,
                               user_scopes_for_collection(@collection_C),
                               list_conf: {})

      ########### CHILDREN ######################################
      expect(select_collections(@p.child_media_resources.resources))
        .to be_empty

      expect(select_media_entries(@p.child_media_resources.resources).length)
        .to be 3
      expect(select_media_entries(@p.child_media_resources.resources).map(&:uuid))
        .to include @media_entry_1.id
      expect(select_media_entries(@p.child_media_resources.resources).map(&:uuid))
        .to include @media_entry_2.id
      expect(select_media_entries(@p.child_media_resources.resources).map(&:uuid))
        .to include @media_entry_4.id

    end

    it 'context collection_D' do
      @p = described_class.new(@collection_D,
                               @user,
                               user_scopes_for_collection(@collection_D),
                               list_conf: {})

      ########### CHILDREN ######################################
      expect(select_media_entries(@p.child_media_resources.resources))
        .to be_empty
      expect(select_collections(@p.child_media_resources.resources))
        .to be_empty
    end
  end
end
