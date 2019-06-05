module Presenters
  module AppView
    class LayoutData < Presenter

      # TODO: AppView/Layout Presenter.
      #       most views are resourceful, so they have #resource
      #       *could* be initialized from responder `AppView.new(resource: @get)`
      # def initialize(resource:)
      #   fail 'TypeError!' unless resource.is_a?(Presenters::AppResource)
      #   @resource = resource
      # end
      # attr_accessor :resource

      def initialize(user:)
        fail 'TypeError!' unless (user.nil? or user.is_a?(User))
        @user = user
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
            favorite_sets_url: my_dashboard_section_path(:favorite_collections),
            groups: my_dashboard_section_path(:groups)
          },
          admin: admin_menu,
          sign_out_action: { url: sign_out_path, method: 'POST' }
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
          href: with_extra_params('/login/zhdk', default_url_options))
        end

        if switch_aai then logins.push(
          id: 'aai',
          title: I18n.t(:login_provider_aai_title),
          description: I18n.t(:login_provider_aai_hint),
          href: shibboleth_sign_in_url)
        end

        # NOTE: DB login is always enabled,
        #       can have a different title if its the only login method
        logins.push(
          id: 'system',
          title: I18n.t(:login_box_internal)
        )

        @_login_providers = logins
      end

      private

      def uberadmin_mode
        @user.admin.webapp_session_uberadmin_mode
      end

      def shibboleth_sign_in_url
        target_url = with_extra_params(
          Settings.shibboleth_sign_in_url_target,
          default_url_options)

        with_extra_params(
          Settings.shibboleth_sign_in_url_base,
          target: target_url)
      end

      def with_extra_params(url, extra_params = {})
        u = URI.parse(url)
        query = u.query ? Rack::Utils::parse_query(u.query) : {}
        u.query = query.to_h.merge(extra_params).to_query
        u.to_s
      end

    end
  end
end
