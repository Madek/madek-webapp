module Concerns
  module MediaResources
    extend ActiveSupport::Concern

    include Concerns::Entrust
    include Concerns::MediaResources::EditSessions
    include Concerns::MediaResources::Favoritable
    include Concerns::MediaResources::MetaData
    include Concerns::MediaResources::PermissionsAssociations
    include Concerns::MediaResources::Visibility
    include Concerns::Users::Creator
    include Concerns::Users::Responsible

    def self.included(base)
      unless base.const_defined?(:ENTRUSTED_PERMISSION)
        base.const_set(:ENTRUSTED_PERMISSION, :get_metadata_and_previews)
      end
    end
  end
end
