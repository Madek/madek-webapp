module Concerns
  module AccessHelpers
    extend ActiveSupport::Concern
    include Concerns::QueryHelpers

    module ClassMethods
      def define_access_methods(prefix, perm_type, *scopes)
        define_method "#{prefix}_user?" do |user|
          self.class
            .send("#{prefix}_user", user)
            .exists?(id: id)
        end

        define_singleton_method "#{prefix}_group" do |group|
          by_group(group, perm_type)
        end

        # if block is not given it is assumed that the user
        # scope is defined in the parent scope otherwise we
        # do this default using passed in scopes via block
        if block_given?
          define_singleton_method "#{prefix}_user" do |user|
            scopes = yield(user)
            scope_strings = scopes.map(&:to_sql)
            sql = join_query_strings_with_union(*scope_strings)
            from(sql)
          end
        end
      end

      def by_group(group, perm_type)
        by_subject(:group, group.id, perm_type)
      end

      def by_user_directly(user, perm_type)
        by_subject(:user, user.id, perm_type)
      end

      def by_user_through_groups(user, perm_type)
        by_subject(:group, user.groups.map(&:id), perm_type)
      end

      def by_subject(type, ids, perm_type)
        ids = [ids] unless ids.is_a?(Array)
        s_name = model_name.singular

        joins("#{type}_permissions".to_sym)
          .where("#{s_name}_#{type}_permissions.#{type}_id IN (?)", ids)
          .where("#{s_name}_#{type}_permissions" \
                 ".#{perm_type} IS TRUE")
      end
    end
  end
end
