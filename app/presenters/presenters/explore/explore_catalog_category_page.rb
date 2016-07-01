module Presenters
  module Explore
    class ExploreCatalogCategoryPage < Presenter
      include Presenters::Explore::Modules::MemoizedHelpers
      include Presenters::Explore::Modules::ExploreNavigation

      def initialize(user, settings, meta_key_id)
        @user = user
        @settings = settings
        # @active_section_id = 'catalog'
        @meta_key = MetaKey.find(meta_key_id)
        @context_key = @meta_key.context_keys.find_by(context_id: 'upload')
        @catalog_category_title = @context_key.description
        @page_title_parts = [settings.catalog_title, @context_key.label]
      end

      def sections
        [catalog_categories_section].compact
      end

      private

      def catalog_categories_section
        unless keywords_for_meta_key_and_public_entries(@meta_key).blank?
          { type: 'catalog_category',
            data: catalog_categories_overview,
            show_all_link: false }
        end
      end

      def catalog_categories_overview
        {
          title: @catalog_category_title,
          list:  keywords_for_meta_key_and_public_entries(@meta_key).map do |kw|
            Presenters::Keywords::KeywordIndexForExplore.new(kw, @user)
          end
        }
      end

      def keywords_for_meta_key_and_public_entries(meta_key)
        @keywords_for_meta_key_and_public_entries ||= \
          Keyword.with_usage_count
          .joins('INNER JOIN meta_data ' \
                 'ON meta_data.id = meta_data_keywords.meta_datum_id')
          .joins('INNER JOIN media_entries ' \
                 'ON media_entries.id = meta_data.media_entry_id')
          .where(media_entries: \
                   { id: MediaEntry.viewable_by_user_or_public(@user) })
          .where(meta_data: { meta_key: meta_key })
          .limit(10)
      end
    end
  end
end
