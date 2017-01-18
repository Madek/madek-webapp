module Presenters
  module Collections
    class CollectionHeader < Presenters::Shared::AppResource

      include Presenters::Shared::Modules::Favoritable

      def initialize(
        app_resource,
        user,
        show_collection_selection: false,
        search_term: '')

        super(app_resource)
        @user = user
        @show_collection_selection = show_collection_selection
        @search_term = search_term
        @p_collection = Presenters::Collections::PresCollection.new(@app_resource)
      end

      def collection_selection
        if @show_collection_selection
          template = 'Presenters::' +
            @app_resource.class.name.pluralize +
            '::' +
            @app_resource.class.name + 'SelectCollection'

          template.constantize.new(
            @user,
            @app_resource,
            @search_term)
        end
      end

      def title
        @p_collection.title
      end

      def url
        collection_path(@app_resource)
      end

      def buttons
        buttons = [
          edit_button,
          favor_button,
          cover_button,
          destroy_button,
          select_collection_button,
          highlight_button,
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
          action: edit_context_meta_data_collection_path(@app_resource),
          allowed: policy_for(@user).meta_data_update?
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
            "#{favored ? 'disfavor' : 'favor'}_collection_path", @app_resource),
          allowed: favored ? policy_for(@user).disfavor? : policy_for(@user).favor?
        }
      end

      def cover_button
        {
          async_action: nil,
          method: 'get',
          icon: 'cover',
          title: I18n.t(:resource_action_edit_cover, raise: false),
          action: cover_edit_collection_path(@app_resource),
          allowed: policy_for(@user).update_cover?
        }
      end

      def destroy_button
        {
          async_action: nil,
          method: 'get',
          icon: 'trash',
          title: I18n.t(:resource_action_destroy, raise: false),
          action: ask_delete_collection_path(@app_resource),
          allowed: policy_for(@user).destroy?
        }
      end

      def select_collection_button
        {
          async_action: 'select_collection',
          method: 'get',
          icon: 'move',
          title: I18n.t(:resource_action_manage_collections, raise: false),
          action: select_collection_collection_path(@app_resource),
          allowed: policy_for(@user).add_remove_collection?
        }
      end

      def highlight_button
        {
          async_action: nil,
          method: 'get',
          icon: 'highlight',
          title: I18n.t(:resource_action_edit_highlights, raise: false),
          action: highlights_edit_collection_path(@app_resource),
          allowed: policy_for(@user).update_highlights?
        }
      end

      def custom_urls_button
        {
          async_action: nil,
          method: 'get',
          icon: 'vis-graph',
          title: I18n.t(:resource_action_edit_custom_urls, raise: false),
          action: custom_urls_collection_path(@app_resource),
          allowed: policy_for(@user).update_custom_urls?
        }
      end
    end
  end
end
