module ErrorsHelper
  def error_500_message
    if Settings.madek_support_email.present?
      t(:error_500_message_pre) + Settings.madek_support_email + t(:error_500_message_post)
    else
      t(:error_500_message)
    end
  end
end
