module Presenters
  module MediaEntries
    module Modules
      module MediaEntryCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon
        include Presenters::Shared::Modules::Favoritable

        def initialize(app_resource, user, list_conf: {})
          fail 'TypeError!' unless app_resource.is_a?(MediaEntry)
          @app_resource = app_resource
          @user = user
          @list_conf = list_conf
          @media_file = Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
        end

        included do

          attr_reader :media_file

          def title
            super.presence or "(Upload from #{@app_resource.created_at.iso8601})"
          end

          def published?
            # NOTE: using #try because MediaEntry instantiated via
            # `vw_media_resources` view does not have such attribute currently
            @app_resource.try(:is_published)
          end

          def url
            prepend_url_context media_entry_path(@app_resource)
          end

        end
      end
    end
  end
end
