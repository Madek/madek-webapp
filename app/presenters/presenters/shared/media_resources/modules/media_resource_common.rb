module Presenters
  module Shared
    module MediaResources
      module Modules
        module MediaResourceCommon
          extend ActiveSupport::Concern
          include Presenters::Shared::MediaResources::Modules::CommonMetaData
          include Presenters::Shared::MediaResources::Modules::Responsible
          include Presenters::Shared::MediaResources::Modules::URLHelpers
        end
      end
    end
  end
end
