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

describe Presenters::MediaEntries::MediaEntryRelations do
  include_context 'relations'
  include_context 'select media resources'

  # TODO: using shared example together with shared context does
  # not work here. All the included instance variables are nil.
  # context 'dumps' do
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@media_entry_1, @user) }
  #   end
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@media_entry_2, @user) }
  #   end
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@media_entry_3, @user) }
  #   end
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@media_entry_4, @user) }
  #   end
  #   it_can_be 'dumped' do
  #     let(:presenter) { described_class.new(@media_entry_5, @user) }
  #   end
  # end

  context 'relations' do
    after :example do
      ########### CHILDREN ######################################
      # NOTE: no such api for media_entry relations
      expect(@p.respond_to?(:child_media_resources)).to be false

      ########### SIBLINGS ######################################
      # NOTE: for now we are ignoring siblings other then collections
      expect(select_media_entries(@p.sibling_media_resources.media_resources).size)
        .to be 0
      expect(select_filter_sets(@p.sibling_media_resources.media_resources).size)
        .to be 0
    end

    it 'context media_entry_1' do
      @p = described_class.new(@media_entry_1, @user)

      ########### PARENTS #######################################
      expect(select_collections(@p.parent_media_resources.media_resources).size)
        .to be 3
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_A.id
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_B.id
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_C.id

      ########### SIBLINGS ######################################
      # NOTE: for now we are ignoring siblings other then collections
      expect(select_collections(@p.sibling_media_resources.media_resources).size)
        .to be 2
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_B.id
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_C.id
    end

    it 'context media_entry_3' do
      @p = described_class.new(@media_entry_3, @user)

      ########### PARENTS #######################################
      expect(select_collections(@p.parent_media_resources.media_resources).size)
        .to be 1
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_B.id

      ########### SIBLINGS ######################################
      expect(select_collections(@p.sibling_media_resources.media_resources).size)
        .to be 0
    end

    it 'context media_entry_4' do
      @p = described_class.new(@media_entry_4, @user)

      ########### PARENTS #######################################
      expect(select_collections(@p.parent_media_resources.media_resources).size)
        .to be 1
      expect(select_collections(@p.parent_media_resources.media_resources)
        .map(&:uuid))
        .to include @collection_C.id

      ########### SIBLINGS ######################################
      expect(select_collections(@p.sibling_media_resources.media_resources).size)
        .to be 0
    end

    it 'context media_entry_5' do
      @p = described_class.new(@media_entry_5, @user)

      ########### PARENTS #######################################
      expect(select_collections(@p.parent_media_resources.media_resources).size)
        .to be 0

      ########### SIBLINGS ######################################
      expect(select_collections(@p.sibling_media_resources.media_resources).size)
        .to be 0
    end
  end
end
