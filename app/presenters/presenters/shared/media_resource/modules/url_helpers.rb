module Presenters
  module Shared
    module MediaResource
      module Modules
        module URLHelpers
          extend ActiveSupport::Concern

          included do

            private

            def generic_thumbnail_url
              ActionController::Base.helpers.image_path \
                Madek::Constants::Webapp::UI_GENERIC_THUMBNAIL[:unknown]
            end

            # TODO: review
            def incomplete_thumbnail_url
              ActionController::Base.helpers.image_path \
                Madek::Constants::Webapp::UI_GENERIC_THUMBNAIL[:incomplete]
            end
          end

        end
      end
    end
  end
end
