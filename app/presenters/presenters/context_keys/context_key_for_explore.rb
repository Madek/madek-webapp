module Presenters
  module ContextKeys
    class ContextKeyForExplore < Presenters::Shared::AppResource

      def initialize(app_resource, user, limit)
        super(app_resource)
        @meta_key = @app_resource.meta_key
        @user = user
        @limit = limit
      end

      def label
        @app_resource.label.presence || @meta_key.label
      end

      def usage_count
        MetaDatum
          .where(media_entry_id: \
            MediaEntry.viewable_by_user_or_public(@user).reorder(nil))
          .where(meta_key: @meta_key)
          .count
      end

      def url
        prepend_url_context "/explore/catalog/#{@app_resource.id}"
      end

      def description
        @app_resource.description
      end

      def image_url
        prepend_url_context \
          preview_paths_for_keywords_path \
            category: @app_resource.id,
            preview_size: :medium,
            limit: @limit
      end
    end
  end
end
