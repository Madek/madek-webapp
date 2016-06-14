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

      def published
        if publishable
          @app_resource.is_published
        else
          true
        end
      end

      # TODO: do this in View:
      def image_url
        @resource_index.image_url
      end

      # TODO: do this in View:
      def title
        @resource_index.title.presence
      end

      private

      def publishable
        @app_resource.class == MediaEntry
      end

    end
  end
end
