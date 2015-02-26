module Presenters
  module Shared
    module Resources
      class ResourceShow < Presenter
        include Presenters::Shared::Resources::Modules::URLHelpers

        attr_reader :relations

        def initialize(resource, user)
          @resource = resource
          @user = user
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
      end
    end
  end
end
