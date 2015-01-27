module Concerns
  module Users
    module Responsible
      extend ActiveSupport::Concern

      included do
        define_user_related_data(:responsible_user)
        scope :in_responsibility_of, ->(user) { where(responsible_user: user) }
      end
    end
  end
end
