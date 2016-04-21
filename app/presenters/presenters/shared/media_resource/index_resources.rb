module Presenters
  module Shared
    module MediaResource
      class IndexResources < Presenter
        include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

        def initialize(user, resources)
          @user = user
          @given_resources = resources
        end

        def resources(resources = @given_resources)
          resources.map do |resource|
            presenter = presenter_by_class(resource.class)
            presenter.new(resource, @user, {})
          end
        end

      end
    end
  end
end
