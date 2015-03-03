module Presenters
  module Shared
    module MediaResources
      class MediaResourceShow < Presenter

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
