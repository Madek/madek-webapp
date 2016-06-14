module Presenters
  module ContextKeys
    class ContextKeyForExplore < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        super(app_resource)
        @meta_key = @app_resource.meta_key
        @user = user
      end

      delegate_to_app_resource :label

      def usage_count
        MetaDatum.where(meta_key: @meta_key).count
      end

      def url
        "/explore/catalog/#{@meta_key.id}"
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

        "/media/#{preview.id}"
      end
    end
  end
end
