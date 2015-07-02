require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'
require Rails.root.join 'spec',
                        'presenters',
                        'shared',
                        'media_resources',
                        'relations_setup'

describe Presenters::Collections::CollectionRelations do
  include_context 'relations'

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
      # NOTE: for now we are ignoring siblings other then collections
      expect(@p.sibling_media_resources.media_entries)
        .to be_empty
      expect(@p.sibling_media_resources.filter_sets)
        .to be_empty
    end

    it 'context collection_A' do
      @p = described_class.new(@collection_A, @user)

      ########### CHILDREN ######################################
      expect(@p.child_media_resources.collections.total_count)
        .to be 2
      expect(@p.child_media_resources.collections.resources.map(&:uuid))
        .to include @collection_B.id
      expect(@p.child_media_resources.collections.resources.map(&:uuid))
        .to include @collection_C.id

      expect(@p.child_media_resources.media_entries.total_count)
        .to be 1
      expect(@p.child_media_resources.media_entries.resources.map(&:uuid))
        .to include @media_entry_1.id

      expect(@p.child_media_resources.filter_sets)
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
      expect(@p.child_media_resources.collections.total_count)
        .to be 0

      expect(@p.child_media_resources.media_entries.total_count)
        .to be 3
      expect(@p.child_media_resources.media_entries.resources.map(&:uuid))
        .to include @media_entry_1.id
      expect(@p.child_media_resources.media_entries.resources.map(&:uuid))
        .to include @media_entry_2.id
      expect(@p.child_media_resources.media_entries.resources.map(&:uuid))
        .to include @media_entry_3.id

      expect(@p.child_media_resources.filter_sets)
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
      expect(@p.child_media_resources.collections)
        .to be_empty

      expect(@p.child_media_resources.media_entries.total_count)
        .to be 3
      expect(@p.child_media_resources.media_entries.resources.map(&:uuid))
        .to include @media_entry_1.id
      expect(@p.child_media_resources.media_entries.resources.map(&:uuid))
        .to include @media_entry_2.id
      expect(@p.child_media_resources.media_entries.resources.map(&:uuid))
        .to include @media_entry_4.id

      expect(@p.child_media_resources.filter_sets)
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
      expect(@p.child_media_resources.collections)
        .to be_empty
      expect(@p.child_media_resources.media_entries)
        .to be_empty
      expect(@p.child_media_resources.filter_sets)
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
