require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'
require Rails.root.join 'spec',
                        'presenters',
                        'shared',
                        'media_resources',
                        'relations_setup'

describe Presenters::MediaEntries::MediaEntryShow do
  include_context 'relations'

  context 'dumps' do
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@media_entry_1, @user).relations }
    end
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@media_entry_2, @user).relations }
    end
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@media_entry_3, @user).relations }
    end
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@media_entry_4, @user).relations }
    end
    it_can_be 'dumped' do
      let(:presenter) { described_class.new(@media_entry_5, @user).relations }
    end
  end

  context 'relations' do
    after :example do
      ########### CHILDREN ######################################
      # NOTE: no such api for media_entry relations
      expect(@p.respond_to?(:child_media_resources)).to be false

      ########### SIBLINGS ######################################
      # NOTE: for now we are ignoring siblings other then collections
      expect(@p.sibling_media_resources.media_entries)
        .to be_empty
      expect(@p.sibling_media_resources.filter_sets)
        .to be_empty
    end

    it 'context media_entry_1' do
      @p = described_class.new(@media_entry_1, @user).relations

      ########### PARENTS #######################################
      expect(@p.parent_media_resources.collections.total_count)
        .to be 3
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_A.id
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_B.id
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_C.id

      ########### SIBLINGS ######################################
      # NOTE: for now we are ignoring siblings other then collections
      expect(@p.sibling_media_resources.collections.total_count)
        .to be 2
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_B.id
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_C.id
    end

    it 'context media_entry_3' do
      @p = described_class.new(@media_entry_3, @user).relations

      ########### PARENTS #######################################
      expect(@p.parent_media_resources.collections.total_count)
        .to be 1
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_B.id

      ########### SIBLINGS ######################################
      expect(@p.sibling_media_resources.collections)
        .to be_empty
    end

    it 'context media_entry_4' do
      @p = described_class.new(@media_entry_4, @user).relations

      ########### PARENTS #######################################
      expect(@p.parent_media_resources.collections.total_count)
        .to be 1
      expect(@p.parent_media_resources.collections.resources.map(&:uuid))
        .to include @collection_C.id

      ########### SIBLINGS ######################################
      expect(@p.sibling_media_resources.collections)
        .to be_empty
    end

    it 'context media_entry_5' do
      @p = described_class.new(@media_entry_5, @user).relations

      ########### PARENTS #######################################
      expect(@p.parent_media_resources.collections)
        .to be_empty

      ########### SIBLINGS ######################################
      expect(@p.sibling_media_resources.collections)
        .to be_empty
    end
  end
end
