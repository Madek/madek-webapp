class My::SettingsController < ApplicationController

  before_action do
    auth_authorize :dashboard, :logged_in?
  end

  def update
    setting_params = params.fetch(:setting)
    user_attributes = {}
    if setting_params.key?(:show_all_data_tab_in_edit_mode)
      user_attributes[:settings] = current_user.settings.merge(
        "show_all_data_tab_in_edit_mode" => ActiveRecord::Type::Boolean.new.cast(
          setting_params[:show_all_data_tab_in_edit_mode])
      )
    end

    if current_user.beta_tester_notifications?
      user_attributes[:emails_locale] = setting_params.fetch(:emails_locale)

      new_settings =
        setting_params.fetch(:notification_case_user_settings, [])
      NotificationCase.all.map do |nc|
        new_setting = new_settings.find { |cs| cs.fetch(:label) == nc.label }
        if new_setting
          case_setting = current_user
            .notification_case_user_settings
            .find_or_initialize_by(notification_case_label: nc.label)
          case_setting
            .update!(email_frequency: new_setting.fetch(:email_frequency))
        end
      end
    end

    current_user.update!(user_attributes) if user_attributes.present?

    render json: {
      emails_locale: current_user.emails_locale,
      show_all_data_tab_in_edit_mode: current_user.show_all_data_tab_in_edit_mode?,
      notification_case_user_settings: current_user.notification_case_user_settings
    }
  end

end
