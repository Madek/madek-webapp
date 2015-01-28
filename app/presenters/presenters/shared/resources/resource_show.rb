module Presenters
  module Shared
    module Resources
      class ResourceShow < Presenter

        def initialize(resource)
          @resource = resource
        end

        def title
          @resource.title
        end

        def description
          @resource.description
        end

        def keywords
          @resource.keywords.map(&:to_s)
        end

        def responsible
          @resource.responsible_user.person.to_s
        end

      end
    end
  end
end
