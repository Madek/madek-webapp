module Presenters
  module Explore
    module Modules
      module ExploreCatalogSection

        private

        def catalog_section
          unless catalog_context_keys.blank?
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
            list: catalog_context_keys.map do |c_key|
              Presenters::ContextKeys::ContextKeyForExplore.new(c_key, @user)
            end
          }
        end
      end
    end
  end
end
