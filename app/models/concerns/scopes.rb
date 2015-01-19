module Concerns
  module Scopes
    extend ActiveSupport::Concern

    included do

      scope :favored_by, lambda { |user|
        joins("INNER JOIN favorite_#{table_name} " \
              "ON favorite_#{table_name}.#{model_name.singular}_id " \
              "= #{table_name}.id")
          .where('favorite_media_entries.user_id = ?', user.id)
      }

      scope :in_responsibility_of, ->(user) { where(responsible_user: user) }
      scope :created_by, ->(user) { where(creator: user) }

    end
  end
end
