module Concerns
  module Keywords
    extend ActiveSupport::Concern

    included do
      has_many :keywords
    end
  end
end
