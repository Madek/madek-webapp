module Concerns
  module MadekCookieSession
    extend ActiveSupport::Concern
    include ::MadekOpenSession

    COOKIE_NAME = Madek::Constants::MADEK_SESSION_COOKIE_NAME
    MADEK_DISABLE_HTTPS = Madek::Constants::MADEK_DISABLE_HTTPS

    def set_madek_session(user, remember = false)
      # NOTE: we do NOT need to protect against session fixation attack,
      #       because a separate cookie for the login session is used:
      #       http://guides.rubyonrails.org/v4.2/security.html#session-fixation-countermeasures

      # NOTE: manually setting cookies, must apply security options ourselves:
      #       http://api.rubyonrails.org/v4.2.7.1/classes/ActionDispatch/Cookies.html
      cookies[COOKIE_NAME] = {
        expires: remember ? 2.weeks.from_now : nil,
        value: build_session_value(user),
        httponly: true,
        secure: (Rails.env == 'production' && !MADEK_DISABLE_HTTPS)
      }
      user.update_attributes! last_signed_in_at: Time.zone.now
      users_group = AuthenticationGroup.find_or_initialize_by \
        id: Madek::Constants::SIGNED_IN_USERS_GROUP_ID
      users_group.name ||= 'Signed-in Users'
      users_group.save! unless users_group.persisted?
      users_group.users << user unless users_group.users.include?(user)
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
        Rails.logger.debug e
        cookies.delete COOKIE_NAME
        nil
      end
    end

    def session_cookie
      cookies[COOKIE_NAME] || \
        raise(StandardError, 'MadekCookieSession: Service cookie not found.')
    end

  end

end
