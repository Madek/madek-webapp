module Concerns
  module PermissionsAssociations
    extend ActiveSupport::Concern

    included do
      %w(api_client group user).each do |assoc_name|
        has_many \
          "#{assoc_name}_permissions".to_sym,
          class_name: "Permissions::#{name}#{assoc_name.camelize}Permission"
      end
    end

    def public?
      get_metadata_and_previews
    end

  end
end
