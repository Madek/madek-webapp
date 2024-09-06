# rubocop:disable Metrics/ClassLength
module Presenters
  module Users
    class UserDashboard < Presenter

      include Presenters::Shared::Clipboard

      def initialize(
            user, user_scopes,
            dashboard_header,
            list_conf: nil,
            activity_stream_conf: nil,
            with_count: true,
            action: nil,
            is_async_attribute: false,
            json_path: nil,
            type_filter: nil,
            sub_filters: nil
      )
        fail 'TypeError!' unless user.is_a?(User)
        @user = user
        @config = { page: 1 }.merge(list_conf)
        @activity_stream_conf = activity_stream_conf
        @user_scopes = user_scopes
        @dashboard_header = dashboard_header
        # FIXME: remove this config when Dashboard is built in Presenter…
        @with_count = with_count
        @action = action
        @is_async_attribute = is_async_attribute
        @json_path = json_path
        @type_filter = type_filter
        @sub_filters = sub_filters
      end

      attr_reader :dashboard_header
      attr_reader :action

      def activity_stream
        return unless @is_async_attribute

        default_date_range = 3.days
        conf = @activity_stream_conf || {}
        user = @user

        start_date = if conf[:from].is_a?(ActiveSupport::TimeWithZone)
          conf[:from] # serve with requested parameters
        else
          DateTime.current # no config, like when initial sync rendering
        end
        date_range = conf[:range].try(:>, 0) ? conf[:range] : default_date_range

        # PERF: we "rewind" the start date to the earlist one that has a result!
        # NOTE: this is a slight but efficient hack, see comment in presenter
        stream_start_date = Presenters::Users::UserActivityStream
          .latest_activity_date(user, start_date) || start_date

        stream_end_date = (stream_start_date - date_range)

        Presenters::Users::UserActivityStream.new(
          user,
          start_date: stream_start_date, end_date: stream_end_date,
          paginated: conf.try(:[], :paginated) == true)
      end

      def notifications
        {
          notification_case_labels: NotificationCase.all.map { |nc| nc.label},
          notifications: @user.notifications
            .where(acknowledged: false)
            .order(created_at: :DESC),
          delegations: Delegation
            .where(id: @user.notifications.where(acknowledged: false).select(:via_delegation_id))
            .order(:name)
        }
      end

      def settings
        notification_case_user_settings = NotificationCase.all.map do |nc|
          ncus = @user.notification_case_user_settings.find_by_notification_case_label(nc.label)
          {
            label: nc.label,
            allowed_email_frequencies: nc.allowed_email_frequencies,
            email_frequency: ncus&.email_frequency&.to_sym || Madek::Constants::DEFAULT_NOTIFICATION_EMAILS_FREQUENCY,
          }
        end
        {
          notifications_url: my_dashboard_section_path(:notifications),
          save_url: my_settings_path,
          email: @user.email,
          emails_locale: @user.emails_locale_with_default_fallback,
          available_locales: AppSetting.available_locales,
          notification_case_user_settings: notification_case_user_settings
        }
      end

      def workflows
        [{
          name: 'My Event Pics',
          is_active: true
        }]
      end

      def unpublished_entries
        return unless @is_async_attribute
        presenterify(
          @user_scopes[:unpublished_media_entries], only_filter_search: true)
      end

      def content_media_entries
        return unless @is_async_attribute
        presenterify @user_scopes[:content_media_entries]
      end

      def content_collections
        return unless @is_async_attribute
        presenterify(
          @user_scopes[:content_collections], disable_file_search: true)
      end

      def content_delegated_media_entries
        return unless @is_async_attribute
        presenterify @user_scopes[:content_delegated_media_entries]
      end

      def content_delegated_collections
        return unless @is_async_attribute
        presenterify @user_scopes[:content_delegated_collections]
      end

      def latest_imports
        return unless @is_async_attribute
        presenterify @user_scopes[:latest_imports]
      end

      def favorite_media_entries
        return unless @is_async_attribute
        presenterify @user_scopes[:favorite_media_entries]
      end

      def favorite_collections
        return unless @is_async_attribute
        presenterify(
          @user_scopes[:favorite_collections], disable_file_search: true)
      end

      def entrusted_media_entries
        return unless @is_async_attribute
        presenterify @user_scopes[:entrusted_media_entries], info_header: entrusted_resources_info_header
      end

      def entrusted_collections
        return unless @is_async_attribute
        presenterify(
          @user_scopes[:entrusted_collections], disable_file_search: true, info_header: entrusted_resources_info_header)
      end

      # def clipboard
      #   return unless @is_async_attribute
      #   if @user and clipboard_collection(@user)
      #     presenterify_clipboard
      #   end
      # end

      def groups_and_delegations
        groups = {
          internal: select_groups(:Group),
          external: select_groups(:InstitutionalGroup),
          authentication: select_groups(:AuthenticationGroup)
        }.transform_values do |groups|
          groups.map { |group| Presenters::Groups::GroupIndex.new(group, @user) }
        end

        Pojo.new(
          empty?: groups.values.flatten.empty?,
          internal: groups[:internal],
          authentication: groups[:authentication],
          external: groups[:external],
          delegations: delegations
        )
      end

      def used_keywords
        is_section_view = (@action && @action == 'dashboard_section')
        per_page = (is_section_view ? 200 : 24)
        @user_scopes[:used_keywords].page(1).per(per_page).map \
          { |k| Presenters::Keywords::KeywordIndexWithUsageCount.new(k) }
      end

      def tokens
        Presenters::Users::UserApiTokens.new(@user)
      end

      private

      def presenterify(
        resources,
        disable_file_search: false,
        only_filter_search: false,
        info_header: nil)

        return if resources.nil?
        Presenters::Shared::MediaResource::MediaResources.new(
          resources,
          @user,
          list_conf: @config,
          with_count: @with_count,
          disable_file_search: disable_file_search,
          only_filter_search: only_filter_search,
          json_path: @json_path, 
          sub_filters: @sub_filters,
          info_header: info_header
        )
      end

      def unpaged_groups(type)
        @user_scopes[:user_groups]
          .where(type: type)
          .order(
            (type == :InstitutionalGroup) ? :institutional_name : :name
          )
      end

      def select_groups(type)
        is_section_view = (@action && @action == 'index')
        if is_section_view
          unpaged_groups(type)
        else
          unpaged_groups(type)
            .page(1)
            .per(20)
        end
      end

      def delegations
        @user_scopes[:user_delegations].order(:name).map do |delegation|
          Presenters::Delegations::DelegationIndex.new(delegation)
        end
      end

      def entrusted_resources_info_header
        return unless @config[:page] == 1
        auth_groups = @user.groups.filter{ |x| x["type"] == "AuthenticationGroup" }
        if auth_groups.any?
          {
            type: "entrustment",
            authentication_group_names: auth_groups.map(&:name),
            groups_url: my_groups_path
          }
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
