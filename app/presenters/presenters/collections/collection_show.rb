module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::AppResource

      include Presenters::Collections::Modules::CollectionCommon
      include Presenters::Shared::MediaResource::Modules::PrivacyStatus
      include Presenters::Shared::MediaResource::Modules::EditSessions

      def initialize(app_resource,
                     user,
                     user_scopes,
                     action: 'show',
                     list_conf: nil,
                     type_filter: nil,
                     show_collection_selection: false,
                     search_term: '',
                     load_meta_data: false)
        super(app_resource, user)
        @user_scopes = user_scopes
        @type_filter = type_filter
        @list_conf = list_conf
        @show_collection_selection = show_collection_selection
        @search_term = search_term
        @load_meta_data = load_meta_data
        # NOTE: this is just a hack to help separating the methods by action/tab
        #       modal actions are all still on top of 'show'
        @active_tab = action
      end

      # <mainTab>
      delegate_to_app_resource :layout

      def summary_meta_data
        return unless @active_tab == 'show'
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
          .collection_summary_context
      end

      def child_media_resources
        return unless @active_tab == 'show'
        # NOTE: filtering is not implemented (needs spec)
        mr_scope = \
          case @type_filter
          when 'entries' then @user_scopes[:child_media_entries]
          when 'collections' then @user_scopes[:child_collections]
          else @user_scopes[:child_media_resources]
          end

        Presenters::Collections::ChildMediaResources.new(
          mr_scope,
          @user,
          can_filter: false,
          list_conf: @list_conf,
          load_meta_data: @load_meta_data)
      end

      def highlighted_media_resources
        return unless @active_tab == 'show'
        resources = @user_scopes[:highlighted_media_entries].concat(
          @user_scopes[:highlighted_collections])
        Presenters::Shared::MediaResource::IndexResources.new(
          @user,
          resources
        )
      end

      def sorting
        return unless @active_tab == 'show'
        @app_resource.sorting
      end
      # </mainTab>

      # <otherTabs>
      def relations
        return unless @active_tab == 'relations'
        _relations
      end

      def permissions
        return unless ['permissions', 'permissions_edit'].include?(@active_tab)
        Presenters::Collections::CollectionPermissionsShow.new(
          @app_resource, @user)
      end

      def all_meta_data
        return unless @active_tab == 'more_data'
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
          .by_vocabulary
      end

      def edit_sessions
        return unless @active_tab == 'more_data'
        super
      end
      # </otherTabs>

      # shared:

      def header
        Presenters::Collections::CollectionHeader.new(
          @app_resource,
          @user,
          show_collection_selection: @show_collection_selection,
          search_term: @search_term)
      end

      def logged_in
        true if @user
      end

      def tabs
        tabs_config.select do |tab|
          policy(@user).send("#{tab[:id]}?")
        end.reject do |tab|
          tab[:id] == 'relations' \
            && _relations.child_collections.empty? \
            && _relations.parent_collections.empty? \
            && _relations.sibling_collections.empty?
        end
      end

      private

      # NOTE: this is only needed for fetching MetaData in Box ListView
      #       MUST be consistent with the MediaEntry!
      #       it is only used via sparse-request, prevent dumping with 'private'
      def meta_data
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
      end

      # NOTE: used by tab helper, because tab should not be shown if no relations
      def _relations
        @_relations ||= Presenters::Collections::CollectionRelations.new(
          @app_resource,
          @user,
          @user_scopes,
          list_conf: @list_conf,
          load_meta_data: @load_meta_data)
      end

      def tabs_config
        # NOTE: tab id = action name = route pathname
        [
          {
            id: 'show',
            label: I18n.t(:collection_tab_main),
            href: collection_path(@app_resource) },
          {
            id: 'relations',
            label: I18n.t(:media_entry_tab_relations),
            href: relations_collection_path(@app_resource) },
          {
            id: 'more_data',
            label: I18n.t(:media_entry_tab_more_data),
            href: more_data_collection_path(@app_resource) },
          {
            id: 'permissions',
            icon_type: :privacy_status_icon,
            label: I18n.t(:media_entry_tab_permissions),
            href: permissions_collection_path(@app_resource) }
        ]
      end
    end
  end
end
