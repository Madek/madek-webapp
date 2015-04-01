module Concerns
  module Entrust
    extend ActiveSupport::Concern

    included do
      scope :entrusted_to_group, lambda { |group|
        entrusted_to_subject(:group, group.id)
      }

      scope :entrusted_to_user_directly, lambda { |user|
        entrusted_to_subject(:user, user.id)
      }

      scope :entrusted_to_user_through_groups, lambda { |user|
        entrusted_to_subject(:group, user.groups.map(&:id))
      }

      def self.entrusted_to_subject(type, ids)
        ids = [ids] unless ids.is_a?(Array)
        s_name = model_name.singular

        joins("#{type}_permissions".to_sym)
          .where("#{s_name}_#{type}_permissions.#{type}_id IN (?)", ids)
          .where("#{s_name}_#{type}_permissions" \
                 ".#{self::ENTRUSTED_PERMISSION} IS TRUE")
      end

      private_class_method :entrusted_to_subject
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
  end
end
