module Presenters
  module MetaData
    class EditContextMetaData \
        < Presenters::Shared::MediaResource::MediaResourceEdit

      attr_reader :context_id

      def initialize(app_resource, user, context_id)
        super(app_resource, user)
        @context_id = context_id
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

      def title
        @app_resource.title.presence or
          "(Upload from #{@app_resource.created_at.iso8601})"
      end

      private

      def publishable
        @app_resource.class == MediaEntry
      end

    end
  end
end
