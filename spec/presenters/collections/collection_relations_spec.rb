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

  # TODO: using shared example together with shared context does
  # not work here. All the included instance variables are nil.
  # context 'dumps' do
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@collection_A, @user) }
  #   end
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@collection_B, @user) }
  #   end
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@collection_C, @user) }
  #   end
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@collection_D, @user) }
  #   end
  # end

  context 'relations' do
    after :example do
      # NOTE: for now we are ignoring siblings other then collections
      expect(select_media_entries(@p.sibling_media_resources.media_resources).size)
        .to be 0
      expect(select_filter_sets(@p.sibling_media_resources.media_resources).size)
        .to be 0
    end

    it 'context collection_A' do
      @p = described_class.new(@collection_A, @user)

      ########### CHILDREN ######################################
      expect(select_collections(@p.child_media_resources.media_resources).size)
        .to be 2
      expect(select_collections(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_B.id
      expect(select_collections(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_C.id

      expect(select_media_entries(@p.child_media_resources.media_resources).size)
        .to be 1
      expect(select_media_entries(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @media_entry_1.id

      expect(select_filter_sets(@p.child_media_resources.media_resources).size)
        .to be 0

      ########### PARENTS #######################################
      expect(select_collections(@p.parent_media_resources.media_resources))
        .to be_empty
      ########### SIBLINGS ######################################
      expect(select_collections(@p.sibling_media_resources.media_resources))
        .to be_empty
    end

    it 'context collection_B' do
      @p = described_class.new(@collection_B, @user)

      ########### CHILDREN ######################################
      expect(select_collections(@p.child_media_resources.media_resources).size)
        .to be 0

      expect(select_media_entries(@p.child_media_resources.media_resources).size)
        .to be 3
      expect(select_media_entries(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @media_entry_1.id
      expect(select_media_entries(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @media_entry_2.id
      expect(select_media_entries(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @media_entry_3.id

      expect(select_filter_sets(@p.child_media_resources.media_resources).size)
        .to be 0

      ########### PARENTS #######################################
      expect(select_collections(@p.parent_media_resources.media_resources).size)
        .to be 1
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_A.id

      ########### SIBLINGS ######################################
      expect(select_collections(@p.sibling_media_resources.media_resources).size)
        .to be 1
      expect(select_collections(@p.sibling_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_C.id
    end

    it 'context collection_C' do
      @p = described_class.new(@collection_C, @user)

      ########### CHILDREN ######################################
      expect(select_collections(@p.child_media_resources.media_resources).size)
        .to be 0

      expect(select_media_entries(@p.child_media_resources.media_resources).size)
        .to be 3
      expect(select_media_entries(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @media_entry_1.id
      expect(select_media_entries(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @media_entry_2.id
      expect(select_media_entries(@p.child_media_resources.media_resources)
        .map(&:uuid))
        .to include @media_entry_4.id

      expect(select_filter_sets(@p.child_media_resources.media_resources).size)
        .to be 0

      ########### PARENTS #######################################
      expect(select_collections(@p.parent_media_resources.media_resources).size)
        .to be 1
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_A.id

      ########### SIBLINGS ######################################
      expect(select_collections(@p.sibling_media_resources.media_resources).size)
        .to be 1
      expect(select_collections(@p.sibling_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_B.id
    end

    it 'context collection_D' do
      @p = described_class.new(@collection_D, @user)

      ########### CHILDREN ######################################
      expect(select_collections(@p.child_media_resources.media_resources).size)
        .to be 0
      expect(select_media_entries(@p.child_media_resources.media_resources).size)
        .to be 0
      expect(select_filter_sets(@p.child_media_resources.media_resources).size)
        .to be 0

      ########### PARENTS #######################################
      expect(select_collections(@p.parent_media_resources.media_resources).size)
        .to be 0

      ########### SIBLINGS ######################################
      expect(select_collections(@p.sibling_media_resources.media_resources).size)
        .to be 0
    end
  end
end
