require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'
require Rails.root.join 'spec',
                        'presenters',
                        'shared',
                        'media_resources',
                        'relations_setup'

describe Presenters::MediaEntries::MediaEntryShow do
  include_context 'relations'

  def user_scopes_for_media_entry(media_entry)
    { parent_collections: \
        media_entry.parent_collections.viewable_by_user_or_public(@user),
      sibling_collections: \
        media_entry.sibling_collections.viewable_by_user_or_public(@user) }
  end

  context 'dumps' do
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(
          @media_entry_1,
          @user,
          user_scopes_for_media_entry(@media_entry_1),
          list_conf: {}).relations
      end
    end
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(
          @media_entry_2,
          @user,
          user_scopes_for_media_entry(@media_entry_2),
          list_conf: {}).relations
      end
    end
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(
          @media_entry_3,
          @user,
          user_scopes_for_media_entry(@media_entry_3),
          list_conf: {}).relations
      end
    end
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(
          @media_entry_4,
          @user,
          user_scopes_for_media_entry(@media_entry_4),
          list_conf: {}).relations
      end
    end
    it_can_be 'dumped' do
      let(:presenter) do
        described_class.new(
          @media_entry_5,
          @user,
          user_scopes_for_media_entry(@media_entry_5),
          list_conf: {}).relations
      end
    end
  end

  context 'relations' do
    after :example do
      ########### CHILDREN ######################################
      # NOTE: no such api for media_entry relations
      expect(@p.respond_to?(:child_media_resources)).to be false

      ########### SIBLINGS ######################################
      # NOTE: for now we are ignoring siblings other then collections
      if (siblings = @p.sibling_collections.resources).present?
        expect(siblings.map(&:class).uniq)
          .to eq [Presenters::Collections::CollectionIndex]
      end
    end

    it 'context media_entry_1' do
      @p = described_class.new(@media_entry_1,
                               @user,
                               user_scopes_for_media_entry(@media_entry_1),
                               list_conf: {}).relations

      ########### PARENTS #######################################
      expect(@p.parent_collections.resources.count)
        .to be 3
      expect(@p.parent_collections.resources.map(&:uuid))
        .to include @collection_A.id
      expect(@p.parent_collections.resources.map(&:uuid))
        .to include @collection_B.id
      expect(@p.parent_collections.resources.map(&:uuid))
        .to include @collection_C.id

      ########### SIBLINGS ######################################
      # NOTE: for now we are ignoring siblings other then collections
      expect(@p.sibling_collections.resources.count)
        .to be 2
      expect(@p.parent_collections.resources.map(&:uuid))
        .to include @collection_B.id
      expect(@p.parent_collections.resources.map(&:uuid))
        .to include @collection_C.id
    end

    it 'context media_entry_3' do
      @p = described_class.new(@media_entry_3,
                               @user,
                               user_scopes_for_media_entry(@media_entry_3),
                               list_conf: {}).relations

      ########### PARENTS #######################################
      expect(@p.parent_collections.resources.count)
        .to be 1
      expect(@p.parent_collections.resources.map(&:uuid))
        .to include @collection_B.id

      ########### SIBLINGS ######################################
      expect(@p.sibling_collections.resources)
        .to be_empty
    end

    it 'context media_entry_4' do
      @p = described_class.new(@media_entry_4,
                               @user,
                               user_scopes_for_media_entry(@media_entry_4),
                               list_conf: {}).relations

      ########### PARENTS #######################################
      expect(@p.parent_collections.resources.count)
        .to be 1
      expect(@p.parent_collections.resources.map(&:uuid))
        .to include @collection_C.id

      ########### SIBLINGS ######################################
      expect(@p.sibling_collections.resources)
        .to be_empty
    end

    it 'context media_entry_5' do
      @p = described_class.new(@media_entry_5,
                               @user,
                               user_scopes_for_media_entry(@media_entry_5),
                               list_conf: {}).relations

      ########### PARENTS #######################################
      expect(@p.parent_collections.resources)
        .to be_empty

      ########### SIBLINGS ######################################
      expect(@p.sibling_collections.resources)
        .to be_empty
    end
  end
end
