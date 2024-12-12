module Presenters
  module Explore
    module Modules
      class ExploreFeaturedContentSection < Presenter

        include AuthorizationSetup
        include AllowedSorting

        def initialize(user, settings)
          @user = user
          @settings = settings
        end

        def empty?
          featured_set_content.blank?
        end

        def content
          return if empty?
          {
            type: 'thumbnail',
            id: 'featured-content',
            data: featured_set_overview,
            show_all_link: true,
            show_all_text: I18n.t(:explore_show_more),
            show_title: true
          }
        end

        private

        def featured_set_overview # list of Collections
          {
            title: localize(@settings.featured_set_titles),
            url: collection_path(featured_set),
            list: Presenters::Shared::MediaResource::IndexResources.new(
              @user,
              featured_set_content,
              async_cover: true
            )
          }
        end

        def load_concrete_models(resources)
          resources.map do |r|
            if r.class == MediaResource
              case r.type
              when 'MediaEntry' then MediaEntry.unscoped.find(r.id)
              when 'Collection' then Collection.unscoped.find(r.id)
              else
                raise "Unknown media resource type: #{r.type}"
              end
            else
              r
            end
          end
        end

        def featured_set
          unless (feat = @settings.featured_set_id.presence)
            return
          end
          Collection.find_by_id(feat)
        end

        def featured_set_content
          @featured_set_content ||= \
            begin
              unless (set = featured_set)
                return
              end

              order = allowed_sorting(set)

              load_concrete_models(
                auth_policy_scope(@user, set.child_media_resources)
                  .custom_order_by(order)
                  .limit(6)
              )
            end
        end
      end
    end
  end
end
