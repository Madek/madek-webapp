module Presenters
  module Explore
    module Modules
      class ExploreLatestSection < Presenter
        include AuthorizationSetup

        def initialize(user, settings)
          @user = user
          @settings = settings
        end

        def empty?
          !latest_media_entries.exists?
        end

        def content
          return if empty?
          {
            type: 'thumbnail',
            id: 'latest-media-entries',
            data: \
              { title: I18n.t(:home_page_new_contents),
                url: media_entries_path(list_conf: { order: 'created_at DESC' }),
                list: Presenters::Shared::MediaResource::IndexResources.new(
                  @user,
                  latest_media_entries
                )
              },
            show_all_link: true,
            show_all_text: I18n.t(:explore_show_more),
            show_title: true
          }
        end

        private

        def latest_media_entries
          @latest_media_entries ||= \
            auth_policy_scope(@user, MediaEntry)
            .reorder(created_at: :desc)
            .limit(12)
        end
      end
    end
  end
end
