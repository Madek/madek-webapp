module Concerns
  module Associations
    extend ActiveSupport::Concern

    included do

      belongs_to :responsible_user, class_name: 'User'
      belongs_to :creator, class_name: 'User'

      has_many :keywords

      has_many :edit_sessions, dependent: :destroy
      has_many :editors, through: :edit_sessions, source: :user

      has_and_belongs_to_many \
        :users_who_favored,
        join_table: "favorite_#{table_name}",
        class_name: 'User'

      has_many \
        :user_permissions,
        class_name: "Permissions::#{name}UserPermission"
      has_many \
        :group_permissions,
        class_name: "Permissions::#{name}GroupPermission"

    end
  end
end
