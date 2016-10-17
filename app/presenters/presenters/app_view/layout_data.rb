module Presenters
  module AppView
    class LayoutData < Presenter

      # TODO: AppView/Layout Presenter.
      #       most views are resourceful, so they have #resource
      #       *could* be initialized from responder `AppView.new(resource: @get)`
      #
      # def initialize(resource:)
      #   fail 'TypeError!' unless resource.is_a?(Presenters::AppResource)
      #   @resource = resource
      # end
      # attr_accessor :resource

      # NOTE: for now just collect all the needed data for layout

      def initialize(user:, settings:, url:, auth_token:)
        fail 'TypeError!' unless (user.nil? || user.is_a?(User))
        @user = user
        @settings = settings
        @url = url
        @auth_token = auth_token
      end

      attr_accessor :url
      attr_accessor :auth_token # for CSRF protection

      def config
        @settings.to_h
          .slice(:site_title, :brand_text, :brand_logo_url, :sitemap)
          .merge(root_path: root_path)
      end

      def sitemap
        @settings.sitemap
      end

      def version
        MADEK_VERSION
      end

      # TMP: duplicated from application/_app_header.haml!
      def header(user = @user, settings = @settings)
        my_menu = user && {
          text: I18n.t(:sitemap_my_archive),
          href: my_dashboard_path,
          active: link_active?(my_dashboard_path)
        }
        search_paths = [media_entries_path, collections_path, filter_sets_path]
        search_active = link_active?(search_path) ||
          search_paths.any? { |p| link_active?(p, deep: true) }

        {
          show_user_menu: !link_active?(root_path),
          menu: {
            my: my_menu,
            explore: {
              text: I18n.t(:sitemap_explore),
              href: explore_path,
              active: link_active?(explore_path)
            },

            search: {
              text: I18n.t(:sitemap_search),
              icon: 'lens',
              href: search_path,
              active: search_active
            },

            help: { text: I18n.t(:sitemap_help), href: settings.support_url }
          }.to_a
        }
      end

      def user_menu
        return unless @user.present?

        admin_menu = if @user.admin?
          { url: prepend_url_context('/admin'), super_action: :not_implemented }
        end

        {
          user_name: Presenters::Users::UserIndex.new(@user).name,
          import_url: new_media_entry_path,
          my: {
            drafts_url: my_dashboard_section_path(:unpublished_entries),
            entries_url: my_dashboard_section_path(:content_media_entries),
            sets_url: my_dashboard_section_path(:content_collections),
            favorite_entries_url: my_dashboard_section_path(
              :favorite_media_entries),
            favorite_sets_url: my_dashboard_section_path(:favorite_collections),
            groups: my_dashboard_section_path(:groups)
          },
          admin: admin_menu,
          sign_out_action: { url: sign_out_path, method: 'POST' }
        }
      end

      def login_link
        '/#login_form'
      end

      private

      def link_active?(link, deep: false)
        path = URI.parse(url).path
        if deep || link == '/' # NOTE: root path can only be checked 'deep'!
          path == link
        else
          path.starts_with?(link)
        end
      end

    end
  end
end
