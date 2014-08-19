module Concerns
  module SetSession
    def set_madek_session user
      session[:user_id] = user.id
      session[:expires_at] = Time.now + 1.week
      session[:pw_sig] = Digest::SHA1.base64digest(user.password_digest)
    end
  end
end

