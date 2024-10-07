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

      def system_login_provider
        {
          id: 'system',
          title: I18n.t(:login_box_internal),
          url: sign_in_path(return_to: return_to)
        }
      end

      def login_providers
        return @_login_providers if @_login_providers.is_a?(Array) # memo
        logins = []

        zhdk_agw = Settings.zhdk_integration && Settings.zhdk_agw_api_url.present?
        switch_aai = Settings.shibboleth_sign_in_enabled == true \
          && Settings.shibboleth_sign_in_url_base.present? \
          && Settings.shibboleth_sign_in_url_target.present?
        fail 'too many logins!' if zhdk_agw and switch_aai

        if zhdk_agw then logins.push(
          id: 'zhdk',
          title: I18n.t(:login_provider_zhdk_title),
          description: I18n.t(:login_provider_zhdk_hint),
          href: with_extra_params('/login/zhdk', default_url_options.merge(return_to: return_to)))
        end

        if switch_aai then logins.push(
          id: 'aai',
          title: I18n.t(:login_provider_aai_title),
          description: I18n.t(:login_provider_aai_hint),
          href: shibboleth_sign_in_url)
        end

        # NOTE: DB login is always enabled,
        #       can have a different title if its the only login method
        logins.push system_login_provider

        @_login_providers = logins
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
