module Presenters
  module AppView
    class LayoutData < Presenter

      def initialize(user:, return_to:, auth_anti_csrf_token:)
        fail 'TypeError!' unless (user.nil? or user.is_a?(User))
        @user = user
        @return_to = return_to
        @auth_anti_csrf_token = auth_anti_csrf_token
      end

      def user_menu
        return unless @user.present?

        admin_menu = if @user.admin?
          {
            url: prepend_url_context('/admin'),
            admin_mode_toggle: {
              url: toggle_uberadmin_path,
              method: 'POST',
              title: (if uberadmin_mode
                        I18n.t(:user_menu_admin_mode_toogle_off)
                      else
                        I18n.t(:user_menu_admin_mode_toogle_on)
                      end)
            }
          }
        end

        user_index = Presenters::Users::UserIndex.new(@user)

        {
          user_name: user_index.name,
          import_url: user_index.import_url,
          my: {
            drafts_url: my_dashboard_section_path(:unpublished_entries),
            clipboard_url: my_dashboard_section_path(:clipboard),
            entries_url: my_dashboard_section_path(:content_media_entries),
            sets_url: my_dashboard_section_path(:content_collections),
            favorite_entries_url: \
              my_dashboard_section_path(:favorite_media_entries),
            person_url: person_path(@user.person),
            favorite_sets_url: my_dashboard_section_path(:favorite_collections),
            groups: my_dashboard_section_path(:groups)
          },
          admin: admin_menu,
          sign_out_action: @auth_anti_csrf_token.present? ?
            { url: '/auth/sign-out', 
              method: 'POST', 
              mode: 'auth-app',
              auth_anti_csrf_token: @auth_anti_csrf_token,
              auth_anti_csrf_param: "csrf-token" } :
            { url: sign_out_path, 
              method: 'POST',
              mode: 'webapp' }
        }
      end

      private

      attr_reader :return_to

      def uberadmin_mode
        @user.admin.webapp_session_uberadmin_mode
      end

      def shibboleth_sign_in_url
        target_url = with_extra_params(
          Settings.shibboleth_sign_in_url_target,
          default_url_options.merge(
            redirect_to: (return_to.present? and (Settings.madek_external_base_url + return_to))
          )
        )

        with_extra_params(
          Settings.shibboleth_sign_in_url_base,
          target: target_url)
      end

      def with_extra_params(url, extra_params = {})
        u = URI.parse(url)
        query = u.query ? Rack::Utils::parse_query(u.query) : {}
        u.query = query.to_h.merge(extra_params.compact).to_query
        u.to_s
      end

    end
  end
end
