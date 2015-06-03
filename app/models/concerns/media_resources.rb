module Concerns
  module MediaResources
    extend ActiveSupport::Concern

    include Concerns::Entrust
    include Concerns::MediaResources::EditSessions
    include Concerns::MediaResources::Favoritable
    include Concerns::MediaResources::Filters::Filters
    include Concerns::MediaResources::MetaData
    include Concerns::MediaResources::PermissionsAssociations
    include Concerns::MediaResources::Visibility
    include Concerns::Users::Creator
    include Concerns::Users::Responsible
  end
end
