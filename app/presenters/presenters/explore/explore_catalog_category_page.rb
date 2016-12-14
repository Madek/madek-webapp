module Presenters
  module Explore
    class ExploreCatalogCategoryPage < Presenter
      include Presenters::Explore::Modules::MemoizedHelpers
      include Presenters::Explore::Modules::ExploreNavigation

      def initialize(user, settings, context_key_id)
        @user = user
        @settings = settings
        # @active_section_id = 'catalog'
        @context_key = ContextKey.find(context_key_id)
        @meta_key = @context_key.meta_key
        @catalog_category_title = @context_key.description
        @page_title_parts =
          [
            settings.catalog_title,
            @context_key.label || @meta_key.label
          ]
      end

      def sections
        [catalog_categories_section].compact
      end

      private

      def catalog_categories_section
        unless keywords_for_meta_key_and_visible_entries(@meta_key).blank?
          { type: 'catalog_category',
            data: catalog_categories_overview,
            show_all_link: false }
        end
      end

      def catalog_categories_overview
        {
          title: @catalog_category_title,
          list:  keywords_for_meta_key_and_visible_entries(@meta_key).map do |kw|
            Presenters::Keywords::KeywordIndexForExplore.new(kw, @user)
          end
        }
      end

      def keywords_for_meta_key_and_visible_entries(meta_key)
        Keyword.with_usage_count
          .where(meta_key: meta_key)
          .joins('INNER JOIN meta_data ' \
                 'ON meta_data.id = meta_data_keywords.meta_datum_id')
          .where(
            meta_data: {
              media_entry_id: \
                auth_policy_scope(@user, MediaEntry).joins(:media_file)
            }
          )
          .limit(catalog_category_limit)
      end
    end
  end
end
