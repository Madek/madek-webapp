module Concerns
  module Users
    module Creator
      extend ActiveSupport::Concern

      included do
        belongs_to :creator, class_name: 'User'
        validates_presence_of :creator
        scope :created_by, ->(user) { where(creator: user) }
      end
    end
  end
end
