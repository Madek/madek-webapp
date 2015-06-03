module Concerns
  module MediaResources
    module Editability
      extend ActiveSupport::Concern
      include Concerns::AccessHelpers

      included do
        define_access_methods(:editable_by, self::EDIT_PERMISSION_NAME) do |user|
          [by_user_directly(user, self::EDIT_PERMISSION_NAME),
           by_user_through_groups(user, self::EDIT_PERMISSION_NAME),
           where(responsible_user: user)]
        end
      end
    end
  end
end
