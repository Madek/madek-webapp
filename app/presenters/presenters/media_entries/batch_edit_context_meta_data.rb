module Presenters
  module MediaEntries
    class BatchEditContextMetaData < Presenter

      include Presenters::Shared::Modules::VocabularyConfig

      attr_reader :context_id, :return_to

      def initialize(
        resource_type,
        media_entries,
        user,
        context_id: nil,
        return_to:)

        @resource_type = resource_type
        @entries = media_entries
        @user = user
        @context_id = context_id
        @return_to = return_to
      end

      def resource_type
        @resource_type.name.underscore
      end

      def resources
        Presenters::Shared::MediaResource::IndexResources.new(@user, @entries)
      end

      def batch_entries
        @batch_entries ||=
          begin
            usable_meta_keys_map = {
              'MediaEntry' => usable_meta_keys(
                'MediaEntry',
                usable_vocabularies_for_user),
              'Collection' => usable_meta_keys(
                'Collection',
                usable_vocabularies_for_user)
            }

            @entries.map do |entry|
              Presenters::Shared::MediaResource::BatchMediaResourceEdit.new(
                entry,
                @user,
                usable_meta_keys_map)
            end
          end
      end

      def meta_data
        Presenters::MetaData::MetaDataEdit.new(@entries[0], @user)
      end

      def meta_meta_data
        Presenters::MetaData::MetaMetaDataEdit.new(@user, @entries[0].class)
      end

      def submit_url
        self.send('batch_meta_data_' +
          @resource_type.name.pluralize.underscore + '_path')
      end

      private

      def usable_meta_keys(class_name, usable_vocabularies_for_user)
        MetaKey
          .where("is_enabled_for_#{class_name.underscore.pluralize}" => true)
          .joins(:vocabulary)
          .where(vocabularies: { id: usable_vocabularies_for_user.map(&:id) })
      end

    end
  end
end
