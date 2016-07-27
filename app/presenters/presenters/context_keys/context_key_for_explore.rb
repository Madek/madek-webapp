module Presenters
  module ContextKeys
    class ContextKeyForExplore < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        super(app_resource)
        @meta_key = @app_resource.meta_key
        @user = user
      end

      def label
        @app_resource.label || @meta_key.label
      end

      def usage_count
        MetaDatum.where(meta_key: @meta_key).count
      end

      def url
        prepend_url_context "/explore/catalog/#{@app_resource.id}"
      end

      def image_url
        preview = \
          MediaEntry
          .viewable_by_user_or_public(@user)
          .joins(:meta_data)
          .where(meta_data: { meta_key: @meta_key })
          .reorder('media_entries.created_at DESC')
          .first
          .media_file
          .preview(:medium)

        return unless preview
        prepend_url_context preview_path(preview.id)
      end
    end
  end
end
