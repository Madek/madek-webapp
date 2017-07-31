module Presenters
  module Explore
    class ExploreCatalogCategoryPage < Presenter

      include AuthorizationSetup
      include Presenters::Explore::Modules::ValuesForMetaKey

      def initialize(
        user,
        settings,
        context_key_id,
        page_size: nil,
        start_index: nil)

        @user = user
        @settings = settings
        @context_key_id = context_key_id
        @page_size = page_size
        @start_index = start_index
      end

      def catalog_title
        @settings.catalog_title
      end

      def title
        context_key.label || meta_key.label
      end

      def meta_key_values
        shared_meta_key_values(
          meta_key,
          @user,
          true,
          page_size: @page_size,
          start_index: @start_index)
      end

      private

      def meta_key
        context_key.meta_key
      end

      def context_key
        ContextKey.find(@context_key_id)
      end
    end
  end
end
