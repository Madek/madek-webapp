module Presenters
  module Explore
    module Modules
      module ExploreFeaturedContentSection

        def featured_set_section
          unless featured_set_content.blank?
            { type: 'thumbnail',
              data: featured_set_overview,
              show_all_link: true }
          end
        end

        private

        def featured_set_overview # list of Collections
          {
            title: @featured_set_title,
            url: '/explore/featured_set',
            list: Presenters::Shared::MediaResource::IndexResources.new(
              @user,
              featured_set_content.limit(@limit_featured_set))
          }
        end
      end
    end
  end
end
