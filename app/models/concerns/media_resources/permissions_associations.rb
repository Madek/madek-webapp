module Concerns
  module MediaResources
    module PermissionsAssociations
      extend ActiveSupport::Concern
      include Concerns::PermissionsAssociations

      def public_view?
        get_metadata_and_previews
      end
    end
  end
end
