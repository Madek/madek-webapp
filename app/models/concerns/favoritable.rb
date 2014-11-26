module Concerns

  module Favoritable

    extend ActiveSupport::Concern

    def toggle_by user
      disfavor_by(user) or favor_by(user)
    end

    def favor_by user
      users_who_favored << user unless users_who_favored.exists?(user)
    end

    def disfavor_by user
      users_who_favored.delete(user) if users_who_favored.exists?(user)
    end

  end

end
