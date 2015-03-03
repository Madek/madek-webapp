module Concerns
  module MediaResources
    module EditSessions
      extend ActiveSupport::Concern

      included do
        has_many :edit_sessions, dependent: :destroy
        has_many :editors, through: :edit_sessions, source: :user
      end
    end
  end
end
