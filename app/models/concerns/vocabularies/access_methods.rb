module Concerns
  module Vocabularies
    module AccessMethods
      extend ActiveSupport::Concern
      include Concerns::AccessHelpers

      module ClassMethods
        def define_vocabulary_access_methods(prefix, perm_type)
          define_access_methods prefix, perm_type do |user|
            [where(Hash["enabled_for_public_#{perm_type}", true]),
             by_user_directly(user, perm_type),
             by_user_through_groups(user, perm_type)]
          end
        end
      end
    end
  end
end
