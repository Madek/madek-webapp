class My::SettingsController < ApplicationController

  before_action do
    auth_authorize :dashboard, :logged_in?
  end

  def update
    emails_locale = params[:setting].fetch(:emails_locale)
    current_user.update!(emails_locale: emails_locale)

    new_settings = params[:setting].fetch(:notification_case_user_settings, [])
    NotificationCase.all.map do |nc|
      new_setting = new_settings.find { |cs| cs.fetch(:label) == nc.label }
      if new_setting
        case_setting = current_user.notification_case_user_settings.find_or_initialize_by(notification_case_label: nc.label)
        case_setting.update!(email_frequency: new_setting.fetch(:email_frequency))
      end
    end

    render json: {
      emails_locale: current_user.emails_locale,
      notification_case_user_settings: current_user.notification_case_user_settings
    }
  end

end
