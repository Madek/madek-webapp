module Presenters
  module ContextKeys
    class ContextKeyForExplore < Presenters::Shared::AppResource
      def initialize(app_resource, user)
        super(app_resource)
        @meta_key = @app_resource.meta_key
        @user = user
      end

      def label
        @app_resource.label.presence || @meta_key.label
      end

      def usage_count
        MetaDatum.where(meta_key: @meta_key).count
      end

      def url
        prepend_url_context "/explore/catalog/#{@app_resource.id}"
      end

      def image_url
        keyword = \
          Keyword
          .joins('INNER JOIN meta_data_keywords ' \
                 'ON keywords.id = meta_data_keywords.keyword_id')
          .joins('INNER JOIN meta_data ' \
                 'ON meta_data.id = meta_data_keywords.meta_datum_id')
          .joins('INNER JOIN media_entries ' \
                 'ON media_entries.id = meta_data.media_entry_id')
          .where(media_entries: \
            { id: MediaEntry.viewable_by_user_or_public(@user).reorder(nil) })
          .where(meta_data: { meta_key: @meta_key })
          .reorder('media_entries.created_at DESC')
          .first

        if keyword
          prepend_url_context preview_for_keyword_path(keyword.id, :medium)
        end
      end
    end
  end
end
