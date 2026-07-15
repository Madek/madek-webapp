module Presenters
  module MetaData
    class EditContextMetaData < Presenters::Shared::AppResourceWithUser
      include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

      attr_reader :context_id, :by_vocabularies

      def initialize(app_resource, user, context_id, by_vocabularies)
        super(app_resource, user)
        @context_id = context_id
        @by_vocabularies = by_vocabularies
      end

      # NOTE: nest "Index" for the corresponding resource (instead of inheritance)
      def resource
        presenter_by_class(@app_resource.class).new(@app_resource, @user)
      end

      def url
        path_variable = @app_resource.class.name.underscore + '_path'
        path = self.send(path_variable, @app_resource)
        prepend_url_context path
      end

      def submit_url
        path_var = 'meta_data_' + @app_resource.class.name.underscore + '_path'
        path = self.send(path_var, @app_resource)
        prepend_url_context path
      end

      def meta_meta_data
        Presenters::MetaData::MetaMetaDataEdit.new(@user, @app_resource.class, @app_resource)
      end

      def meta_data
        Presenters::MetaData::MetaDataEdit.new(@app_resource, @user)
      end

      def edit_by_context_urls
        {}.tap do |urls|
          meta_meta_data.meta_data_edit_context_ids.map do |context_id|
            urls[context_id] =
              send(edit_by_context_path_helper, @app_resource, context_id)
          end
        end
      end

      def edit_by_context_fallback_url
        send(edit_by_context_path_helper, @app_resource)
      end

      def batch_edit_by_context_urls
        {}.tap do |urls|
          meta_meta_data.meta_data_edit_context_ids.map do |context_id|
            urls[context_id] = batch_edit_meta_data_by_context_media_entries_path(context_id)
          end
        end
      end

      def batch_edit_by_context_fallback_url
        batch_edit_meta_data_by_context_media_entries_path
      end

      def edit_by_vocabularies_url
        send(edit_by_vocabularies_path_helper, @app_resource)
      end

      def batch_edit_by_vocabularies_url
        batch_edit_meta_data_by_vocabularies_media_entries_path
      end

      def published
        @app_resource.class == MediaEntry ? @app_resource.is_published : true
      end

      def show_all_data_tab_in_edit_mode
        auth_policy(@user, @app_resource).edit_all_meta_data_enabled?
      end

      private

      def edit_by_context_path_helper
        "edit_meta_data_by_context_#{resource_route_name}_path"
      end

      def edit_by_vocabularies_path_helper
        "edit_meta_data_by_vocabularies_#{resource_route_name}_path"
      end

      def resource_route_name
        @app_resource.class.name.underscore
      end
    end
  end
end
