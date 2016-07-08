module Presenters
  module Shared
    module MediaResource
      class IndexResources < Presenter
        include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

        def initialize(user, resources, async_cover: false)
          @user = user
          @given_resources = resources
          @async_cover = async_cover
        end

        def resources(resources = @given_resources)
          resources.includes(:meta_data).map do |resource|
            presenter = presenter_by_class(resource.class)
            if resource.class == Collection
              presenter.new(resource, @user, async_cover: @async_cover)
            else
              presenter.new(resource, @user)
            end
          end
        end

      end
    end
  end
end
