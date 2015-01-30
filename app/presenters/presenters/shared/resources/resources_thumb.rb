module Presenters
  module Shared
    module Resources
      class ResourcesThumb < Presenter

        def initialize(resource)
          @resource = resource
        end

        def title
          @resource.title
        end

        def privacy_status
        end

      end
    end
  end
end
