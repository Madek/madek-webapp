module Controllers
  module Shared

    def valid_session user
      {user_id: user.id,
       expires_at: Time.now + 1.week,
       pw_sig: Digest::SHA1.base64digest(user.password_digest)} 
    end

  end
end

