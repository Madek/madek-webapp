module Presenters
  module Explore
    class ContextKeyForExplore < Presenters::Shared::AppResource

      def initialize(app_resource, user)
        super(app_resource)
        @meta_key = @app_resource.meta_key
        @user = user
      end

      def label
        @app_resource.label.presence || @meta_key.label
      end

      def examples
        Presenters::Explore::KeywordsForExplore.new(@user, @meta_key)
      end

      def usage_count
        MetaDatum
          .where(media_entry_id: auth_policy_scope(@user, MediaEntry).reorder(nil))
          .where(meta_key: @meta_key)
          .count
      end

      def url
        prepend_url_context explore_catalog_category_path(@app_resource.id)
      end

      def description
        @app_resource.description
      end

      def image_url
        prepend_url_context \
          catalog_key_thumb_path \
            category: @app_resource.id,
            preview_size: :medium,
            limit: 24
      end
    end
  end
end
