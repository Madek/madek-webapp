module Concerns
  module Users
    module Creator
      extend ActiveSupport::Concern
      include Concerns::Users::UserHelper

      included do
        define_user_related_data(:creator)
        scope :created_by, ->(user) { where(creator: user) }
      end
    end
  end
end
