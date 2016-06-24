module Presenters
  module Explore
    module Modules
      module ExplorePageCommon

        def page_title
          ['Erkunden']
          .concat(@page_title_parts || [])
          .join(' / ')
        end

        def nav
          catalog = {
            title: @settings.catalog_title,
            id: 'catalog',
            url: '/explore/catalog',
            children: nav_catalog_children
          }

          featured_set = {
            title: @settings.featured_set_title,
            id: 'featured_set',
            url: '/explore/featured_set'
          }

          keywords = {
            title: 'Häufige Schlagworte',
            id: 'keywords',
            url: '/explore/keywords'
          }

          case @active_section_id
          when 'catalog' then catalog[:active] = true
          when 'featured_set' then featured_set[:active] = true
          when 'keywords' then keywords[:active] = true
          end

          [catalog, featured_set, keywords]
        end

        private

        def nav_catalog_children
          @settings.catalog_context_keys.map do |meta_key_id|
            {
              title: find_context_key(meta_key_id).label,
              url: "/explore/catalog/#{meta_key_id}",
              active: (@meta_key.try(:id) == meta_key_id ? true : false)
            }
          end
        end

        def featured_set_overview # list of Collections
          return unless (feat = @settings.featured_set_id.presence)
          return unless (set = Collection.find_by_id(feat))

          authorized_resources = \
            ::Shared::MediaResources::MediaResourcePolicy::Scope.new(
              @user, set.child_media_resources)
            .resolve

          {
            title: @featured_set_title,
            url: '/explore/featured_set',
            list: Presenters::Shared::MediaResource::IndexResources.new(
              @user,
              authorized_resources.limit(@limit_featured_set))
          }
        end

        def keywords
          keywords = \
            MetaKey
            .find_by(id: 'madek_core:keywords')
            .keywords
            .with_usage_count
            .limit(@limit_keywords)

          return unless keywords.present?

          {
            title: 'Häufige Schlagworte',
            url: '/explore/keywords',

            list: keywords.map do |keyword|
              {
                url: prepend_url_context('/explore/catalog/madek_core:keywords'),
                keyword: \
                  Presenters::Keywords::KeywordIndexWithUsageCount.new(keyword)
              }
            end
          }
        end

        def find_context_key(meta_key_id)
          ContextKey.find_by(
            context_id: 'upload',
            meta_key_id: meta_key_id
          )
        end

        def catalog_overview
          # NOTE: limit (of catalog_keys) would be 3, for full page ???
          catalog_context_keys = ContextKey.where(
            context_id: 'upload',
            meta_key_id: @settings.catalog_context_keys
          )

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
