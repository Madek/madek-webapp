module Presenters
  module MetaData
    class MetaDatumShow < Presenters::MetaData::MetaDatumCommon

      def subject_media_resource
        resource = @app_resource.media_entry or
                    @app_resource.collection
        presenter = "Presenters::MediaEntries::#{resource.class.name}Index"
        presenter.constantize.new(resource, @user)
      end

    end
  end
end
