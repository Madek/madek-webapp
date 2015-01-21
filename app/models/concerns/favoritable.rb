module Concerns

  module Favoritable

    extend ActiveSupport::Concern

    def toggle_by(user)
      disfavor_by(user) or favor_by(user)
    end

    def favor_by(user)
      users_who_favored << user unless users_who_favored.exists?(user)
    end

    def disfavor_by(user)
      users_who_favored.delete(user) if users_who_favored.exists?(user)
    end

    included do
      has_and_belongs_to_many \
        :users_who_favored,
        join_table: "favorite_#{table_name}",
        class_name: 'User'

      scope :favored_by, lambda { |user|
        joins("INNER JOIN favorite_#{table_name} " \
              "ON favorite_#{table_name}.#{model_name.singular}_id " \
              "= #{table_name}.id")
          .where("favorite_#{table_name}.user_id = ?", user.id)
      }
    end

  end

end
