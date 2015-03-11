module Presenters
  module Shared
    module MediaResources
      class MediaResourceShow < Presenters::Shared::AppResource

        def description
          @resource.description
        end

        def keywords
          @resource.keywords.map(&:to_s)
        end
      end
    end
  end
end
