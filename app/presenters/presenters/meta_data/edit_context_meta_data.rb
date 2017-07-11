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

      def meta_meta_data
        Presenters::MetaData::MetaMetaDataEdit.new(@user, @app_resource.class)
      end

      def meta_data
        Presenters::MetaData::MetaDataEdit.new(@app_resource, @user)
      end

      def published
        if @app_resource.class == MediaEntry
          @app_resource.is_published
        else
          true
        end
      end
    end
  end
end
