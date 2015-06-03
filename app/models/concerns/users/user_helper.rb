module Concerns
  module Users
    module UserHelper
      extend ActiveSupport::Concern

      included do

        def self.define_user_related_data(user_type)
          belongs_to user_type, class_name: 'User'
          validates_presence_of user_type
        end

      end
    end
  end
end
