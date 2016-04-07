module Presenters
  module Shared
    module MediaResource
      class IndexResources < Presenter
        include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

        attr_reader :resources

        def initialize(user, resources)
          @user = user
          @resources = init_resource_presenters(resources)
        end

        def init_resource_presenters(resources)
          resources.map do |resource|
            presenter = presenter_by_class(resource.class)
            presenter.new(
              resource,
              @user,
              {})
          end
        end

      end
    end
  end
end
