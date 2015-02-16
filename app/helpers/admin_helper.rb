module AdminHelper
  def navbar_item(text, path)
    content_tag :li, class: ('active' if current_page?(path)) do
      link_to text, path
    end
  end

  def alerts
    @alerts.each_pair do |message_type, messages|
      messages.each do |message|
        alert_type = message_type == :error ? :danger : message_type
        yield message_type, message, alert_type
      end
    end
    nil
  end
end
