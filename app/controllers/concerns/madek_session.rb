require 'cider_ci/open_session/encryptor'
require 'cider_ci/open_session/signature'

module Concerns
  module MadekSession
    extend ActiveSupport::Concern

    COOKIE_NAME = 'madek_services-session'

    def set_madek_session(user, remember = false)
      options = if remember
                  { expires: 20.years.from_now }
                else
                  {}
                end

      cookies[COOKIE_NAME] = \
        options.merge(value: CiderCi::OpenSession::Encryptor.encrypt(
          secret, user_id: user.id, signature: create_user_signature(user),
                  issued_at: Time.now.iso8601))
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

    def validate_not_expired!(session_object)
      issued_at = Time.parse(session_object[:issued_at]) || \
        raise(StandardError, 'Issued_at could not be determined!')
      unless issued_at + 1.weeks > Time.now
        raise(StandardError, 'Session object is expired!')
      end
    end

    def session_cookie
      cookies[COOKIE_NAME] || \
        raise(StandardError, 'Service cookie not found.')
    end

    def secret
      Rails.application.secrets.secret_key_base || \
        raise(StandardError, 'secret_key_base must be set!')
    end

    def create_user_signature(user)
      CiderCi::OpenSession::Signature.create \
        secret, user.password_digest
    end

    def validate_user_signature!(user, signature)
      CiderCi::OpenSession::Signature.validate! \
        signature, secret, user.password_digest
    end

  end

end
