module Presenters
  module MediaEntries
    class MediaEntryHeader < Presenters::Shared::AppResource

      include Presenters::Shared::Modules::Favoritable

      def initialize(
        app_resource,
        user,
        show_collection_selection: false,
        search_term: ''
      )

        super(app_resource)
        @user = user
        @show_collection_selection = show_collection_selection
        @search_term = search_term
      end

      delegate_to_app_resource :title

      def collection_selection
        if @show_collection_selection
          template =
            'Presenters::' +
            @app_resource.class.name.pluralize +
            '::' +
            @app_resource.class.name + 'SelectCollection'

          template.constantize.new(
            @user,
            @app_resource,
            @search_term)
        end
      end

      def url
        media_entry_path(@app_resource)
      end

      def buttons
        buttons = [
          edit_button,
          destroy_button,
          favor_button,
          select_collection_button,
          export_button,
          custom_urls_button
        ]
        buttons.select do |tab|
          tab[:allowed] == true
        end
      end

      def edit_button
        {
          async_action: nil,
          method: 'get',
          icon: 'pen',
          title: I18n.t(:resource_action_edit, raise: false),
          action: edit_meta_data_by_context_media_entry_path(@app_resource),
          allowed: policy_for(@user).meta_data_update?
        }
      end

      def destroy_button
        {
          async_action: nil,
          method: 'get',
          icon: 'trash',
          title: I18n.t(:resource_action_destroy, raise: false),
          action: ask_delete_media_entry_path(@app_resource),
          allowed: policy_for(@user).destroy?
        }
      end

      def favor_button
        {
          async_action: nil,
          method: 'patch',
          icon: favored ? 'favorite' : 'nofavorite',
          title: I18n.t(
            "resource_action_#{favored ? 'disfavor' : 'favor'}", raise: false),
          action: self.send(
            "#{favored ? 'disfavor' : 'favor'}_media_entry_path", @app_resource),
          allowed: favored ? policy_for(@user).disfavor? : policy_for(@user).favor?
        }
      end

      def select_collection_button
        {
          async_action: 'select_collection',
          method: 'get',
          icon: 'move',
          title: I18n.t(:resource_action_manage_collections, raise: false),
          action: select_collection_media_entry_path(@app_resource),
          allowed: policy_for(@user).add_remove_collection?
        }
      end

      def export_button
        {
          async_action: nil,
          method: 'get',
          icon: 'dload',
          title: I18n.t(:resource_action_export, raise: false),
          action: export_media_entry_path(@app_resource),
          allowed: policy_for(@user).export?
        }
      end

      def custom_urls_button
        {
          async_action: nil,
          method: 'get',
          icon: 'vis-graph',
          title: I18n.t(:resource_action_edit_custom_urls, raise: false),
          action: custom_urls_media_entry_path(@app_resource),
          allowed: policy_for(@user).update_custom_urls?
        }
      end
    end
  end
end
