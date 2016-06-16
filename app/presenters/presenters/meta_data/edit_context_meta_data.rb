module Presenters
  module MetaData
    class EditContextMetaData \
        < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::Shared::MediaResource::Modules::URLHelpers
      include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

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

      def resource_index
        presenter_by_class(@app_resource.class).new(@app_resource, @user)
      end

      def image_url

        if @app_resource.class == MediaEntry
          media_file = Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
          size = :large
          img = media_file.previews.try(:fetch, :images, nil).try(:fetch, size, nil)
          img.presence ? img.url : generic_thumbnail_url
        else
          nil
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
