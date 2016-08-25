module Presenters
  module Explore
    module Modules
      module ExploreCatalogSection

        private

        def catalog_section
          unless non_empty_catalog_context_keys_presenters.blank?
            { type: 'catalog',
              id: 'catalog',
              data: catalog_overview,
              show_all_link: @show_all_link }
          end
        end

        def catalog_overview
          {
            title: @catalog_title,
            url: '/explore/catalog/',
            list: non_empty_catalog_context_keys_presenters
          }
        end
      end
    end
  end
end
