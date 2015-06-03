module Concerns
  module Vocabularies
    module Usability
      extend ActiveSupport::Concern
      include Concerns::Vocabularies::AccessMethods

      included do
        define_vocabulary_access_methods(:usable_by, :use)
      end
    end
  end
end
