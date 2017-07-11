module Presenters
  module MediaEntries
    class BatchEditContextMetaData < Presenter
      include AuthorizationSetup

      attr_reader :context_id, :return_to, :by_vocabularies

      def initialize(
        resource_type,
        user,
        context_id: nil,
        by_vocabularies: false,
        return_to:,
        entries: nil,
        collection: nil)

        if collection && entries || !collection && !entries
          throw "Unexpected parameters: #{collection}, #{entries}"
        end

        @resource_type = resource_type
        @entries = entries
        @collection = collection
        @user = user
        @context_id = context_id
        @by_vocabularies = by_vocabularies
        @return_to = return_to
      end

      def collection_id
        return unless @collection
        @collection.id
      end

      def resource_type
        @resource_type.name.underscore
      end

      def resources
        if @collection
          if @resource_type == MediaEntry
            Presenters::Shared::MediaResource::IndexResources.new(
              @user, @collection.media_entries.limit(4))
          else
            Presenters::Shared::MediaResource::IndexResources.new(
              @user, @collection.collections.limit(4))
          end
        else
          Presenters::Shared::MediaResource::IndexResources.new(
            @user, @entries.limit(4))
        end
      end

      def batch_length
        if @collection
          if @resource_type == MediaEntry
            @collection.media_entries.count
          else
            @collection.collections.count
          end
        else
          @entries.count
        end
      end

      def at_least_one_published
        if @collection
          true
        elsif @resource_type == Collection
          return true
        else
          @entries.exists?(is_published: true)
        end
      end

      def batch_ids
        if @collection
          nil
        else
          @entries.map(&:id)
        end
      end

      def batch_diff
        if @collection
          Presenters::MediaEntries::BatchDiffQuery.diff(
            @resource_type, collection_id: @collection.id)
        else
          Presenters::MediaEntries::BatchDiffQuery.diff(
            @resource_type, resource_ids: @entries.map(&:id))
        end
      end

      def meta_data
        if @collection
          if @resource_type == MediaEntry
            Presenters::MetaData::MetaDataEdit.new(
              @collection.media_entries[0], @user)
          else
            Presenters::MetaData::MetaDataEdit.new(
              @collection.collections[0], @user)
          end
        else
          Presenters::MetaData::MetaDataEdit.new(
            @entries[0], @user)
        end
      end

      def meta_meta_data
        if @collection
          if @resource_type == MediaEntry
            Presenters::MetaData::MetaMetaDataEdit.new(
              @user, @collection.media_entries[0].class)
          else
            Presenters::MetaData::MetaMetaDataEdit.new(
              @user, @collection.collections[0].class)
          end
        else
          Presenters::MetaData::MetaMetaDataEdit.new(
            @user, @entries[0].class)
        end
      end

      def submit_url
        self.send('batch_meta_data_' +
          @resource_type.name.pluralize.underscore + '_path')
      end
    end
  end
end
