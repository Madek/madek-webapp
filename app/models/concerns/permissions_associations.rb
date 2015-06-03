module Concerns
  module PermissionsAssociations
    extend ActiveSupport::Concern

    included do
      %w(api_client group user).each do |assoc_name|
        has_many \
          "#{assoc_name}_permissions".to_sym,
          class_name: "Permissions::#{name}#{assoc_name.camelize}Permission"
      end

      private

      def user_permission_types_for(user)
        user_permissions
          .where(user_id: user.id)
          .map { |p| select_keys_with_true_value(p) }
          .flatten
      end

      def group_permission_types_for(user)
        group_permissions
          .where(group_id: user.groups.map(&:id))
          .map { |p| select_keys_with_true_value(p) }
          .flatten
      end

      def select_keys_with_true_value(p)
        p.attributes.keep_if { |k, v| v == true }.keys
      end
    end

    def permission_types_for_user(user)
      if responsible_user == user
        "Permissions::Modules::#{self.class.name}::PERMISSION_TYPES".constantize
      else
        (user_permission_types_for(user) + group_permission_types_for(user))
          .map(&:to_sym)
          .uniq
      end
    end
  end
end
