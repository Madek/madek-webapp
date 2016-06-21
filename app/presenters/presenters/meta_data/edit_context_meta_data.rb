module Presenters
  module MetaData
    class EditContextMetaData \
        < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

      attr_reader :context_id, :resource_index

      def initialize(app_resource, user, context_id)
        super(app_resource, user)
        @context_id = context_id
        @resource_index = presenter_by_class(@app_resource.class)
          .new(@app_resource, @user)
      end

      def url
        path_variable = @app_resource.class.name.underscore + '_path'
        path = self.send(path_variable, @app_resource)
        prepend_url_context path
      end

      def meta_meta_data
        Presenters::MetaData::MetaMetaDataEdit.new(@user, @app_resource.class)
      end

      # TODO: do this in View:
      def image_url
        @resource_index.image_url
      end

      # TODO: do this in View:
      def title
        @resource_index.title.presence
      end

    end
  end
end
