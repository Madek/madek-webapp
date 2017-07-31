module Presenters
  module Explore
    module Modules
      class ExploreCatalogSection < Presenter

        def initialize(settings)
          @settings = settings
        end

        def empty?
          non_empty_catalog_context_keys_presenters.blank?
        end

        def content
          return if empty?
          {
            type: 'catalog',
            id: 'catalog',
            data: catalog_overview,
            show_all_link: false,
            show_title: true
          }
        end

        private

        def catalog_overview
          {
            title: @settings.catalog_title,
            url: '/explore/catalog/',
            list: non_empty_catalog_context_keys_presenters
          }
        end

        def non_empty_catalog_context_keys_presenters
          @non_empty_catalog_context_keys_presenters ||= \
            catalog_context_keys.map do |c_key|
              Presenters::Explore::ContextKeyForExplore.new(
                c_key, @user)
            end.select { |p| p.usage_count > 0 }
        end

        def catalog_context_keys
          # NOTE: limit (of catalog_keys) would be 3, for full page ???
          @catalog_context_keys ||= \
            @settings
            .catalog_context_keys \
            .try(:map, & proc { |ck_id| ContextKey.find_by_id(ck_id) })
            .to_a
            .compact
        end
      end
    end
  end
end
