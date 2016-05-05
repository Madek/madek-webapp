module Presenters
  module MediaEntries
    class MediaEntryIndex < Presenters::Shared::MediaResource::MediaResourceIndex

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      def initialize(app_resource, user, list_conf: {}, with_relations: false)
        super(app_resource, user, list_conf: list_conf)
        @with_relations = with_relations
        initialize_relations if with_relations
      end

      def image_url
        size = :medium
        img = @media_file.previews.try(:fetch, :images, nil).try(:fetch, size, nil)
        img.presence ? img.url : generic_thumbnail_url
      end

      def keywords_pretty
        @app_resource.keywords.map(&:to_s).join(', ')
      end

      def authors_pretty
        authors = @app_resource.meta_data.find_by(
          meta_key_id: 'madek_core:authors')
        authors ? authors.value.map(&:to_s).join(', ') : ''
      end

      def subtitle
        meta_data = @app_resource.meta_data.where(
          meta_key_id: 'madek_core:subtitle')
        !meta_data.empty? ? meta_data[0].string : ''
      end

      private

      def parent_relation_resources
        @app_resource.parent_collections
      end

      def child_relation_resources
        nil
      end

    end
  end
end
