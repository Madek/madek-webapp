module Json
  module UserHelper

    def hash_for_user(user, with = nil)
      h = {
        id: user.id,
        name: user.to_s
      }

      if with ||= nil
        [:groups].each do |k|
          h[k] = user.send(k) if with[k]
        end
      end

      h
    end
  end
end
      