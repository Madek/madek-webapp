module Concerns
  module Entrust
    extend ActiveSupport::Concern
    include Concerns::AccessHelpers

    included do
      define_access_methods(:entrusted_to, self::VIEW_PERMISSION_NAME) do |user|
        [by_user_directly(user, self::VIEW_PERMISSION_NAME),
         by_user_through_groups(user, self::VIEW_PERMISSION_NAME)]
      end
    end
  end
end
