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
          context_keys.map do |context_key_id|
            if context_key = find_context_key(context_key_id)
              {
                title: context_key.label || context_key.meta_key.label,
                url: "/explore/catalog/#{context_key.id}",
                active:
                  (@context_key.try(:id) == context_key.id ? true : false)
              }
            else
              next
            end
          end
        end

        def find_context_key(id)
          ContextKey.find_by(id: id)
        end

      end
    end
  end
end
