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

describe Presenters::Collections::CollectionRelations do
  include_context 'relations'
  include_context 'select media resources'

  context 'dumps' do
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@collection_A, @user) }
    end
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@collection_B, @user) }
    end
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@collection_C, @user) }
    end
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@collection_D, @user) }
    end
  end

  context 'relations' do
    after :example do
      # make sure that siblings ALWAYS contain only collections:
      expect(@p.sibling_media_resources.media_entries)
        .to be_empty
      expect(@p.sibling_media_resources.filter_sets)
        .to be_empty
    end

    it 'context collection_A' do
      @p = described_class.new(@collection_A, @user)

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

      expect(select_filter_sets(@p.child_media_resources.resources))
        .to be_empty

      ########### PARENTS #######################################
      expect(@p.parent_media_resources.collections)
        .to be_empty
      ########### SIBLINGS ######################################
      expect(@p.sibling_media_resources.collections)
        .to be_empty
    end

    it 'context collection_B' do
      @p = described_class.new(@collection_B, @user)

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

      expect(select_filter_sets(@p.child_media_resources.resources))
        .to be_empty

      ########### PARENTS #######################################
      expect(@p.parent_media_resources.collections.total_count)
        .to be 1
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_A.id

      ########### SIBLINGS ######################################
      expect(@p.sibling_media_resources.collections.total_count)
        .to be 1
      expect(@p.sibling_media_resources.collections.resources.map(&:uuid))
        .to include @collection_C.id
    end

    it 'context collection_C' do
      @p = described_class.new(@collection_C, @user)

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

      expect(select_filter_sets(@p.child_media_resources.resources))
        .to be_empty

      ########### PARENTS #######################################
      expect(@p.parent_media_resources.collections.total_count)
        .to be 1
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_A.id

      ########### SIBLINGS ######################################
      expect(@p.sibling_media_resources.collections.total_count)
        .to be 1
      expect(@p.sibling_media_resources.collections.resources.map(&:uuid))
        .to include @collection_B.id
    end

    it 'context collection_D' do
      @p = described_class.new(@collection_D, @user)

      ########### CHILDREN ######################################
      expect(select_media_entries(@p.child_media_resources.resources))
        .to be_empty
      expect(select_collections(@p.child_media_resources.resources))
        .to be_empty
      expect(select_filter_sets(@p.child_media_resources.resources))
        .to be_empty

      ########### PARENTS #######################################
      expect(@p.parent_media_resources.collections)
        .to be_empty

      ########### SIBLINGS ######################################
      expect(@p.sibling_media_resources.collections)
        .to be_empty
    end
  end
end
