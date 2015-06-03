module Concerns
  module MediaResources
    module Visibility
      extend ActiveSupport::Concern
      include Concerns::AccessHelpers

      def viewable_by_public?
        get_metadata_and_previews?
      end

      included do
        define_access_methods(:viewable_by, self::VIEW_PERMISSION_NAME)
      end

      module ClassMethods
        def viewable_by_public
          where(Hash[self::VIEW_PERMISSION_NAME, true])
        end

        def viewable_by_user(user)
          scope1 = unscoped.viewable_by_public
          scope2 = unscoped.by_user_directly(user,
                                             self::VIEW_PERMISSION_NAME)
          scope3 = unscoped.by_user_through_groups(user,
                                                   self::VIEW_PERMISSION_NAME)
          scope4 = unscoped.where(responsible_user: user)
          sql = "((#{(current_scope or all).to_sql}) INTERSECT " \
                 "((#{scope1.to_sql}) UNION " \
                  "(#{scope2.to_sql}) UNION " \
                  "(#{scope3.to_sql}) UNION " \
                  "(#{scope4.to_sql}))) AS #{table_name}"
          from(sql)
        end

        def viewable_by_user_or_public(user = nil)
          user ? viewable_by_user(user) : viewable_by_public
        end
      end
    end
  end
end
