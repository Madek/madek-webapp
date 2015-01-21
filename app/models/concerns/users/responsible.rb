module Concerns
  module Users
    module Responsible
      extend ActiveSupport::Concern

      included do
        belongs_to :responsible_user, class_name: 'User'
        validates_presence_of :responsible_user, :creator
        scope :in_responsibility_of, ->(user) { where(responsible_user: user) }
      end
    end
  end
end
