# rubocop:disable Metrics/ClassLength
module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::AppResource

      include Presenters::Collections::Modules::CollectionCommon
      include Presenters::Shared::MediaResource::Modules::PrivacyStatus
      include Presenters::Shared::MediaResource::Modules::EditSessions
      include Presenters::Shared::Modules::VocabularyConfig
      include Presenters::Shared::Modules::MetaDataPerContexts

      def initialize(app_resource,
                     user,
                     user_scopes,
                     action: 'show',
                     context_id: nil,
                     list_conf: nil,
                     children_list_conf: nil,
                     type_filter: nil,
                     show_collection_selection: false,
                     search_term: '',
                     load_meta_data: false)
        super(app_resource, user)
        @user_scopes = user_scopes
        @type_filter = type_filter
        @list_conf = list_conf
        # TMP!
        @children_list_conf = children_list_conf || list_conf
        @show_collection_selection = show_collection_selection
        @search_term = search_term
        @load_meta_data = load_meta_data
        # NOTE: this is just a hack to help separating the methods by action/tab
        #       modal actions are all still on top of 'show'
        @active_tab =
          if ['relation_siblings', 'relation_children', 'relation_parents']
              .include?(action)
            'relations'
          elsif action == 'context'
            'context_' + context_id
          else
            action
          end
        @action = action
        @context_id = context_id
      end

      attr_reader :action
      attr_reader :active_tab

      # <mainTab>

      def layout
        # NOTE: only needed for main tab bc layout is for the children
        return unless @active_tab == 'show'
        @app_resource.layout
      end

      def summary_meta_data
        return unless @action == 'show'
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
          .collection_summary_context
      end

      # for relations tabs
      def relation_resources
        return unless @active_tab == 'relations'

        case @action
        when 'relation_siblings' then _relations.sibling_collections
        when 'relation_children' then _relations.child_collections
        when 'relation_parents' then _relations.parent_collections
        when 'relations' then nil
        else
          fail 'logic error!'
        end
      end

      def child_media_resources
        return unless ['show', 'usage_data'].include?(@active_tab)

        # return unless @action == 'show'

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
          # NOTE: should have class of db view even if using a faster scope:
          item_type: 'MediaResources',
          can_filter: false,
          list_conf: @children_list_conf,
          load_meta_data: @load_meta_data)
      end

      def highlighted_media_resources
        return unless @action == 'show'
        resources = @user_scopes[:highlighted_media_entries] +
          @user_scopes[:highlighted_collections]
        Presenters::Shared::MediaResource::IndexResources.new(
          @user,
          resources
        )
      end

      def sorting
        return unless @action == 'show'
        @app_resource.sorting
      end
      # </mainTab>

      # <otherTabs>
      def relations
        is_relations = ('relations' == @active_tab && @action == 'relations')
        is_usage_data = ('usage_data' == @active_tab)
        return unless (is_relations || is_usage_data)
        _relations
      end

      def permissions
        return unless ['permissions', 'permissions_edit'].include?(@action)
        Presenters::Collections::CollectionPermissions.new(
          @app_resource, @user)
      end

      def all_meta_data
        return unless ['more_data'].include?(@action)
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
          .by_vocabulary
      end

      def edit_sessions
        return unless ['usage_data'].include?(@action)
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
        reduce_tabs_by_policies(show_tab)
          .concat(context_tabs)
          .concat(reduce_tabs_by_policies(other_tabs))
      end

      # context
      def context_meta_data
        return unless @action == 'context'
        build_meta_data_context(@app_resource, @user, Context.find(@context_id))
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

      def reduce_tabs_by_policies(tabs)
        tabs.select do |tab|
          policy_for(@user).send("#{tab[:id]}?")
        end.reject do |tab|
          tab[:id] == 'relations' \
            && _relations.child_collections.empty? \
            && _relations.parent_collections.empty? \
            && _relations.sibling_collections.empty?
        end
      end

      def contexts_for_tabs
        _contexts_for_collection_extra.select do |context|
          meta_data_for_context(@app_resource, @user, context).any?
        end
      end

      def context_tabs
        contexts_for_tabs.map do |c|
          cp = Presenters::Contexts::ContextCommon.new(c)
          next if cp.uuid == 'set_summary'
          {
            id: 'context/' + cp.uuid,
            label: cp.label,
            href: context_collection_path(@app_resource, cp.uuid)
          }
        end
      end

      def show_tab
        [
          {
            id: 'show',
            label: I18n.t(:collection_tab_main),
            href: collection_path(@app_resource)
          }
        ]
      end

      def other_tabs
        # NOTE: tab id = action name = route pathname
        [
          {
            id: 'relations',
            label: I18n.t(:media_entry_tab_relations),
            href: relations_collection_path(@app_resource)
          },
          {
            id: 'usage_data',
            label: I18n.t(:media_entry_tab_usage_data),
            href: usage_data_collection_path(@app_resource)
          },
          {
            id: 'more_data',
            label: I18n.t(:media_entry_tab_more_data),
            href: more_data_collection_path(@app_resource)
          },
          {
            id: 'permissions',
            icon_type: :privacy_status_icon,
            label: I18n.t(:media_entry_tab_permissions),
            href: permissions_collection_path(@app_resource)
          }
        ]
      end

    end
  end
end
