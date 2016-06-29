module Presenters
  module Explore
    module Modules
      module ExploreNavigation

        def page_title
          ['Erkunden']
          .concat(@page_title_parts || [])
          .join(' / ')
        end

        def nav
          [nav_catalog, nav_featured_set, nav_keywords].compact
        end

        private

        def nav_catalog
          unless catalog_context_keys.blank?
            {
              title: @settings.catalog_title,
              id: 'catalog',
              url: '/explore/catalog',
              children: nav_catalog_children,
              active: @active_section_id == 'catalog'
            }
          end
        end

        def nav_featured_set
          unless featured_set_content.blank?
            {
              title: @settings.featured_set_title,
              id: 'featured_set',
              url: '/explore/featured_set',
              active: @active_section_id == 'featured_set'
            }
          end
        end

        def nav_keywords
          unless keywords.blank?
            {
              title: 'Häufige Schlagworte',
              id: 'keywords',
              url: '/explore/keywords',
              active: @active_section_id == 'keywords'
            }
          end
        end

        def nav_catalog_children
          context_keys = @settings.catalog_context_keys || []
          context_keys.map do |meta_key_id|
            {
              title: find_context_key(meta_key_id).label,
              url: "/explore/catalog/#{meta_key_id}",
              active: (@meta_key.try(:id) == meta_key_id ? true : false)
            }
          end
        end

        def find_context_key(meta_key_id)
          ContextKey.find_by(
            context_id: 'upload',
            meta_key_id: meta_key_id
          )
        end

      end
    end
  end
end
