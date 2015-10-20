module Presenters
  module MediaEntries
    module Modules
      module MediaEntryCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon

        def initialize(app_resource, user)
          @app_resource = app_resource
          @user = user
        end

        included do

          def title
            super.presence or "(Upload from #{@app_resource.created_at.iso8601})"
          end

          def published?
            @app_resource.is_published
          end

          def url
            prepend_url_context_fucking_rails media_entry_path(@app_resource)
          end

          private

          def image_url_helper(size)
            result = generic_thumbnail_url # fallback from "superclass"

            media_file = @app_resource.media_file
            if result and media_file.representable_as_image?
              # TODO: for all ResourceThumbs…
              # if media_file.the_preview_was_created_and_should_exist_in_storage
              result = preview_media_entry_path(@app_resource, size)
              # else
              # url = ActionController::Base.helpers.image_path \
              #     ::UI_GENERIC_THUMBNAIL[:incomplete]
            end
            prepend_url_context_fucking_rails result
          end

        end
      end
    end
  end
end
