module Presenters
  module MediaEntries
    module Modules
      module MediaEntryMetaData
        extend ActiveSupport::Concern

        included do

          def meta_data
            Presenters::MetaData::MetaDataEdit.new(@app_resource, @user)
          end

        end
      end
    end
  end
end
