# rubocop:disable Metrics/ClassLength
module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::AppResource

      include Presenters::Collections::Modules::CollectionCommon
      include Presenters::Shared::MediaResource::Modules::PrivacyStatus
      include Presenters::Shared::MediaResource::Modules::EditSessions
      include Presenters::Shared::MediaResource::Modules::SectionLabels
      include Presenters::Shared::Modules::VocabularyConfig
      include Presenters::Shared::Modules::MetaDataPerContexts
      include Presenters::Shared::Modules::PartOfWorkflow

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
                     load_meta_data: false,
                     section_meta_key_id: nil)
        super(app_resource, user)
        @user_scopes = user_scopes
        @type_filter = type_filter
        @list_conf = list_conf
        # TMP!
        @children_list_conf = children_list_conf || list_conf
        @show_collection_selection = show_collection_selection
        @search_term = search_term
        @load_meta_data = load_meta_data
        @section_labels = section_labels(section_meta_key_id, app_resource)
        # NOTE: this is just a hack to help separating the methods by action/tab
        #       modal actions are all still on top of 'show'
        @action = action
        @context_id = context_id
        @active_tab = determine_active_tab
      end

      attr_reader :action
      attr_reader :active_tab

      delegate_to_app_resource :default_context_id

      # <mainTab>

      def collection_selection
        if @show_collection_selection
          Presenters::Collections::CollectionSelectCollection.new(
            @user,
            @app_resource,
            @search_term
          )
        end
      end

      def layout
        return unless %w(show context).include?(action)
        @app_resource.layout
      end

      def summary_meta_data
        return unless %w(show context).include?(action)
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
          .collection_summary_context
      end

      # for relations tabs
      def relation_resources
        return unless active_tab == 'relations'

        _relations_resources(action)
      end

      def child_media_resources
        return unless %(show usage_data).include?(active_tab) || active_tab.start_with?('context_')

        # NOTE: filtering is not implemented (needs spec)
        mr_scope = \
          case @type_filter
          when 'entries' then @user_scopes[:child_media_entries]
          when 'collections' then @user_scopes[:child_collections]
          else @user_scopes[:child_media_resources]
          end

        content_type = \
          case @type_filter
          when 'entries' then MediaEntry
          when 'collections' then Collection
          else
            MediaResource
          end

        Presenters::Collections::ChildMediaResources.new(
          mr_scope,
          @user,
          # NOTE: should have class of db view even if using a faster scope:
          item_type: 'MediaResources',
          can_filter: true,
          list_conf: @children_list_conf,
          load_meta_data: @load_meta_data,
          disable_file_search: @type_filter != 'entries',
          only_filter_search: !['entries', 'collections'].include?(@type_filter),
          content_type: content_type,
          part_of_workflow: part_of_workflow?
        )
      end

      def highlighted_media_resources
        resources = @user_scopes[:highlighted_media_entries] +
          @user_scopes[:highlighted_collections]
        Presenters::Shared::MediaResource::IndexResources.new(
          @user,
          resources
        )
      end

      def sorting
        return unless action.presence_in %w(show context)
        @app_resource.sorting
      end
      # </mainTab>

      # <otherTabs>
      def relations
        is_relations = ('relations' == active_tab && action == 'relations')
        is_usage_data = ('usage_data' == active_tab)
        return unless (is_relations || is_usage_data)
        _relations_overview
      end

      def permissions
        return unless ['permissions', 'permissions_edit'].include?(action)
        Presenters::Collections::CollectionPermissions.new(
          @app_resource, @user)
      end

      def all_meta_data
        return unless ['more_data'].include?(action)
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
          .by_vocabulary
      end

      def edit_sessions
        return unless ['usage_data'].include?(action)
        super
      end

      def relation_counts
        return unless ['usage_data'].include?(action)
        Presenters::MediaResources::RelationCounts.new(@app_resource, @user)
      end
      # </otherTabs>

      # shared:

      def header
        Presenters::Collections::CollectionHeader.new(
          @app_resource,
          @user,
          search_term: @search_term,
          section_labels: @section_labels)
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
        return unless %w(show context).include?(action)
        return unless context_id
        build_meta_data_context(@app_resource, @user, Context.find(context_id))
      end

      def batch_edit_url
        batch_edit_all_collection_path(@app_resource)
      end

      def add_to_set_url
        batch_select_add_to_set_path
      end

      def remove_from_set_url
        batch_ask_remove_from_set_path
      end

      def relations_url
        relations_collection_path(@app_resource)
      end

      def relations_parents_url
        relation_parents_collection_path(@app_resource)
      end

      def relations_siblings_url
        relation_siblings_collection_path(@app_resource)
      end

      def change_position_url
        change_position_collection_path(@app_resource)
      end

      def position_changeable
        policy_for(@user).change_position?
      end

      def new_collection_url
        my_new_collection_path(parent_id: @app_resource.id)
      end

      private

      attr_reader :context_id

      # rubocop:disable CyclomaticComplexity
      # rubocop:disable PerceivedComplexity
      def determine_active_tab
        if ['relation_siblings', 'relation_children', 'relation_parents'].include?(action)
          'relations'
        elsif %(permissions permissions_edit).include?(action)
          'permissions'
        elsif action == 'context' && context_id
          'context_' + context_id
        elsif action == 'show' && context_id && \
          _collection_summary_context.map(&:id).include?(context_id)
          action
        elsif action == 'show' && context_id && \
              @app_resource.default_context_id? && default_context_id == context_id
          'context_' + context_id
        else
          action
        end
      end
      # rubocop:enable CyclomaticComplexity
      # rubocop:enable PerceivedComplexity

      # NOTE: this is only needed for fetching MetaData in Box ListView
      #       MUST be consistent with the MediaEntry!
      #       it is only used via sparse-request, prevent dumping with 'private'
      def meta_data
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
      end

      def _relations_resources(action)
        all_three = Presenters::Collections::CollectionRelations.new(
          @app_resource,
          @user,
          @user_scopes,
          list_conf: @list_conf,
          load_meta_data: @load_meta_data)

        case action
        when 'relation_siblings' then all_three.sibling_collections
        when 'relation_children' then all_three.child_collections
        when 'relation_parents' then all_three.parent_collections
        when 'relations' then nil
        else
          fail 'logic error!'
        end
      end

      # NOTE: used by tab helper, because tab should not be shown if no relations
      def _relations_overview
        @_relations_overview ||= Presenters::Collections::CollectionRelations.new(
          @app_resource,
          @user,
          @user_scopes,
          # NOTE: Do not reuse list_conf, otherwise the filters for the set
          # are applied to the relations overview.
          list_conf: { for_url: @list_conf[:for_url] },
          load_meta_data: @load_meta_data)
      end

      def reduce_tabs_by_policies(tabs)
        tabs.select do |tab|
          policy_for(@user).send("#{tab[:id]}?")
        end.reject do |tab|
          tab[:id] == 'relations' \
            && _relations_overview.child_collections.empty? \
            && _relations_overview.parent_collections.empty? \
            && _relations_overview.sibling_collections.empty?
        end
      end

      def contexts_for_tabs
        _contexts_for_collection_extra.select do |context|
          meta_data_for_context(@app_resource, @user, context).any?
        end
      end

      def context_tabs
        contexts_for_tabs.map do |c|
          next if c.id == 'set_summary'
          cp = Presenters::Contexts::ContextCommon.new(c)
          href = if @app_resource.default_context_id? && default_context_id == cp.uuid
            collection_path(@app_resource)
          else
            context_collection_path(@app_resource, cp.uuid)
          end
          {
            id: 'context_' + cp.uuid,
            label: cp.label,
            href: href
          }
        end
      end

      def show_tab
        href =
          if @app_resource.default_context_id? && \
             _collection_summary_context.first && \
             _collection_summary_context.first.id != default_context_id
            context_collection_path(@app_resource, _collection_summary_context.first.id)
          else
            collection_path(@app_resource)
          end

        [
          {
            id: 'show',
            label: I18n.t(:collection_tab_main),
            href: href
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
