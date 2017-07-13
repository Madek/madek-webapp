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
        Presenters::Shared::MediaResource::IndexResources.new(
          @user, authorized_resources.limit(4))
      end

      def batch_length
        authorized_resources.count
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
        Presenters::MediaEntries::BatchDiffQuery.diff(
          @resource_type, authorized_resources)
      end

      def meta_data
        Presenters::MetaData::MetaDataEdit.new(
          authorized_resources[0], @user)
      end

      def meta_meta_data
        Presenters::MetaData::MetaMetaDataEdit.new(
          @user, authorized_resources[0].class)
      end

      def submit_url
        self.send('batch_meta_data_' +
          @resource_type.name.pluralize.underscore + '_path')
      end

      def counts
        {
          all_resources: all_resources.count,
          authorized_resources: authorized_resources.count
        }
      end

      private

      def all_resources
        @all_resources ||= begin
          if @collection
            if @resource_type == MediaEntry
                @collection.media_entries
            else
                @collection.collections
            end
          else
            @entries
          end
        end
      end

      def authorized_resources
        @authorized_resources ||= begin
          scope = all_resources
          auth_policy_scope(
            @user, scope, MediaResourcePolicy::EditableScope)
        end
      end
    end
  end
end
