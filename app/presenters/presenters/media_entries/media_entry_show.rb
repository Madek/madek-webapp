# rubocop:disable Metrics/ClassLength
module Presenters
  module MediaEntries
    class MediaEntryShow < Presenters::Shared::AppResource

      include Presenters::MediaEntries::Modules::MediaEntryCommon
      include Presenters::Shared::MediaResource::Modules::PrivacyStatus
      include Presenters::Shared::MediaResource::Modules::EditSessions
      include Presenters::Shared::MediaResource::Modules::SectionLabels

      def initialize(
        app_resource,
        user,
        user_scopes,
        action: 'show',
        list_conf: nil,
        show_collection_selection: false,
        search_term: '',
        section_meta_key_id: nil,
        sub_filters: nil)

        super(app_resource, user)
        @user_scopes = user_scopes
        @list_conf = list_conf
        @show_collection_selection = show_collection_selection
        @search_term = search_term
        @section_labels = section_labels(section_meta_key_id, app_resource)
        # NOTE: this is just a hack to help separating the methods by action/tab
        #       modal actions are all still on top of 'show'
        @active_tab =
          if ['relation_siblings', 'relation_children', 'relation_parents']
              .include?(action)
            'relations'
          else
            action
          end
        @action = action
        @sub_filters = sub_filters
      end

      def collection_selection
        if @show_collection_selection
          Presenters::MediaEntries::MediaEntrySelectCollection.new(
            @user,
            @app_resource,
            @search_term
          )
        end
      end

      def tabs # list of all 'show' action sub-tabs
        tabs_config.select do |tab|
          tab[:id] ? policy_for(@user).send("#{tab[:id]}?".to_sym) : true
        end.reject do |tab|
          tab[:id] == 'relations' \
            && _relations.parent_collections.empty? \
            && _relations.sibling_collections.empty?
        end
      end

      def browse_url
        if policy_for(@user).browse?
          prepend_url_context(browse_media_entry_path(@app_resource))
        end
      end

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

      def relations
        is_relations = ('relations' == @active_tab && @action == 'relations')
        is_usage_data = ('usage_data' == @active_tab)
        return unless (is_relations || is_usage_data)
        _relations
      end

      def siblings_url
        prepend_url_context(siblings_media_entry_path(@app_resource))
      end

      def meta_data
        return unless %w(
          show export more_data usage_data show_by_confidential_link
        )
          .include?(@active_tab)
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
      end

      def more_data
        return unless ['usage_data'].include?(@active_tab)
        Presenters::MediaEntries::MediaEntryMoreData.new(@app_resource)
      end

      def edit_sessions
        return unless ['usage_data'].include?(@active_tab)
        super
      end

      def relation_counts
        return unless ['usage_data'].include?(@active_tab)
        Presenters::MediaResources::RelationCounts.new(@app_resource, @user)
      end

      def permissions
        return unless ['permissions', 'permissions_edit'].include?(@active_tab)
        Presenters::MediaEntries::MediaEntryPermissions.new(@app_resource, @user)
      end

      def header
        Presenters::MediaEntries::MediaEntryHeader.new(
          @app_resource,
          @user,
          search_term: @search_term,
          section_labels: @section_labels)
      end

      def image_url
        size = :large
        imgs = self.media_file.try(:previews).try(:fetch, :images, nil)
        img = imgs.try(:fetch, size, nil) || imgs.try(:values).try(:first)
        img.url if img.present?
      end

      def relations_url
        relations_media_entry_path(@app_resource)
      end

      def relations_parents_url
        relation_parents_media_entry_path(@app_resource)
      end

      def relations_siblings_url
        relation_siblings_media_entry_path(@app_resource)
      end

      def export_url
        if policy_for(@user).export?
          export_media_entry_path(@app_resource)
        end
      end

      def rdf_export_urls
        [
          {
            key: :rdf_xml,
            label: 'RDF/XML',
            url: meta_data_media_entry_path(@app_resource, format: 'rdf'),
            plain_text_url: meta_data_media_entry_path(@app_resource, format: 'rdf', txt: 1)
          },
          {
            key: :turtle,
            label: 'Turtle',
            url: meta_data_media_entry_path(@app_resource, format: 'ttl'),
            plain_text_url: meta_data_media_entry_path(@app_resource, format: 'ttl', txt: 1)
          },
          {
            key: :json_ld,
            label: 'JSON-LD',
            url: meta_data_media_entry_path(@app_resource, format: 'json'),
            plain_text_url: meta_data_media_entry_path(@app_resource, format: 'json', txt: 1)
          }
        ]
      end

      private

      # NOTE: used by tab helper, because tab should not be shown if no relations
      def _relations
        @_relations ||= Presenters::Shared::MediaResource::MediaResourceRelations
          .new(@app_resource, @user, @user_scopes, list_conf: @list_conf, sub_filters: @sub_filters)
      end

      def tabs_config
        [
          {
            id: 'show',
            title: I18n.t(:media_entry_tab_main)
          },
          {
            id: 'relations',
            title: I18n.t(:media_entry_tab_relations),
            href: relations_media_entry_path(@app_resource)
          },
          {
            id: 'usage_data',
            title: I18n.t(:media_entry_tab_usage_data),
            href: usage_data_media_entry_path(@app_resource)
          },
          {
            id: 'more_data',
            title: I18n.t(:media_entry_tab_more_data),
            href: more_data_media_entry_path(@app_resource)
          },
          {
            id: 'permissions',
            title: I18n.t(:media_entry_tab_permissions),
            icon_type: :privacy_status_icon,
            href: permissions_media_entry_path(@app_resource)
          }
        ]
      end
    end
  end
end
