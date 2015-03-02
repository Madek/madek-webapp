module AdminHelper
  def navbar_item(text, path)
    content_tag :li, class: ('active' if current_page?(path)) do
      link_to text, path
    end
  end

  def alerts
    @alerts.each_pair do |level, level_content|
      messages = level_content.is_a?(Array) ? level_content : [level_content]
      messages.each do |message|
        bootstrap_level = (level == :error) ? :danger : level
        yield level, message, bootstrap_level if message
      end
    end
    nil
  end
end
