module Presenters
  module Explore
    module Modules
      module ExploreFeaturedContentSection

        private

        def featured_set_section
          unless featured_set_content.blank?
            { type: 'thumbnail',
              id: 'featured-content',
              data: featured_set_overview,
              show_all_link: @show_all_link }
          end
        end

        def featured_set_overview # list of Collections
          {
            title: @featured_set_title,
            url: '/explore/featured_set',
            list: Presenters::Shared::MediaResource::IndexResources.new(
              @user,
              featured_set_content,
              async_cover: true
            )
          }
        end
      end
    end
  end
end
