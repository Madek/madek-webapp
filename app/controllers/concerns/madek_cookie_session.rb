module Concerns
  module MadekCookieSession
    extend ActiveSupport::Concern
    include ::MadekOpenSession

    COOKIE_NAME = Madek::Constants::MADEK_SESSION_COOKIE_NAME

    def set_madek_session(user, remember = false)
      cookies[COOKIE_NAME] = {
        expires: remember ? 20.years.from_now : nil,
        value: build_session_value(user)
      }
    end

    def destroy_madek_session
      cookies.delete COOKIE_NAME
    end

    def validate_services_session_cookie_and_get_user
      begin
        session_object = CiderCi::OpenSession::Encryptor.decrypt(
          secret, session_cookie).deep_symbolize_keys
        user = User.find session_object[:user_id]
        validate_user_signature!(user, session_object[:signature])
        validate_not_expired! session_object
        user
      rescue Exception => e
        Rails.logger.warn e
        cookies.delete COOKIE_NAME
        nil
      end
    end

    def session_cookie
      cookies[COOKIE_NAME] || \
        raise(StandardError, 'Service cookie not found.')
    end

  end

end
