module Presenters
  module Shared
    module MediaResource
      module Modules
        module MediaResourceCommon
          extend ActiveSupport::Concern
          include Presenters::Shared::MediaResource::Modules::CommonMetaData
          include Presenters::Shared::MediaResource::Modules::Responsible
          include Presenters::Shared::MediaResource::Modules::URLHelpers
        end
      end
    end
  end
end
