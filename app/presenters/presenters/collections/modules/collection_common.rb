module Presenters
  module Collections
    module Modules
      module CollectionCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResources::Modules::MediaResourceCommon
        included do
          attr_reader :relations
        end
        def initialize(resource, user)
          @resource = resource
          @user = user
        end
      end
    end
  end
end
