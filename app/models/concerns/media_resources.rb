module Concerns
  module MediaResources
    extend ActiveSupport::Concern

    include Concerns::MediaResources::EditSessions
    include Concerns::MediaResources::Entrust
    include Concerns::MediaResources::Favoritable
    include Concerns::MediaResources::MetaData
    include Concerns::MediaResources::PermissionsAssociations
    include Concerns::Users::Creator
    include Concerns::Users::Responsible
  end
end
