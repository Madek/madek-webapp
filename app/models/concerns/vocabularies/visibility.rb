module Concerns
  module Vocabularies
    module Visibility
      extend ActiveSupport::Concern
      include Concerns::Vocabularies::AccessMethods

      def viewable_by_public?
        enabled_for_public_view?
      end

      included do
        define_vocabulary_access_methods(:viewable_by, :view)
      end

      module ClassMethods
        def viewable_by_user_or_public(user = nil)
          user ? viewable_by_user(user) : where(enabled_for_public_view: true)
        end
      end
    end
  end
end
