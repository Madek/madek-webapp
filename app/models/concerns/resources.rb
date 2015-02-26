module Concerns
  module Resources
    extend ActiveSupport::Concern

    include Concerns::Resources::EditSessions
    include Concerns::Resources::Entrust
    include Concerns::Resources::Favoritable
    include Concerns::Resources::MetaData
    include Concerns::Resources::PermissionsAssociations
    include Concerns::Users::Creator
    include Concerns::Users::Responsible
  end
end
