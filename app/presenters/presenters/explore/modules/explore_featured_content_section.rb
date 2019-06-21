module Presenters
  module Explore
    module Modules
      class ExploreFeaturedContentSection < Presenter

        include AuthorizationSetup
        include Concerns::AllowedSorting

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

              auth_policy_scope(@user, set.child_media_resources)
              .custom_order_by(order)
              .limit(6)
            end
        end
      end
    end
  end
end
