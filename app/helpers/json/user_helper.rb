module Json
  module UserHelper

    def hash_for_user(user, with = nil)
      {
        id: user.id,
        name: user.to_s
      }
    end
  end
end
      