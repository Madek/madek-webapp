module Concerns
  module Resources
    module Entrust
      extend ActiveSupport::Concern

      included do
        s_name = model_name.singular

        scope :entrusted_to_user_directly, lambda { |user|
          joins(:user_permissions)
            .where(
              "#{s_name}_user_permissions.user_id = ? " \
              "AND #{s_name}_user_permissions.get_metadata_and_previews IS TRUE",
              user.id
            )
        }

        scope :entrusted_to_user_through_groups, lambda { |user|
          joins(:group_permissions)
            .where(
              "#{s_name}_group_permissions.group_id IN (?) "\
              "AND #{s_name}_group_permissions.get_metadata_and_previews IS TRUE",
              user.groups.map(&:id)
            )
        }

        private

        def collections_entrusted_to_user(kind, user)
          scope1 = send("#{kind}_collections")
          scope2 = Collection.entrusted_to_user(user)
          sql = "((#{scope1.to_sql}) INTERSECT (#{scope2.to_sql})) AS collections"
          Collection.from(sql)
        end
      end

      module ClassMethods
        def entrusted_to_user(user)
          scope1 = entrusted_to_user_directly(user)
          scope2 = entrusted_to_user_through_groups(user)
          sql = "((#{scope1.to_sql}) UNION (#{scope2.to_sql})) AS #{table_name}"
          from(sql)
        end
      end

      def entrusted_to_user?(user)
        self.class
          .entrusted_to_user(user)
          .where(id: id)
          .exists?
      end

      def parent_collections_entrusted_to_user(user)
        collections_entrusted_to_user(:parent, user)
      end

      def sibling_collections_entrusted_to_user(user)
        collections_entrusted_to_user(:sibling, user)
      end
    end
  end
end
