module AdminHelper
  def navbar_item(text, path)
    content_tag :li, class: ('active' if current_page?(path)) do
      link_to text, path
    end
  end

  def alerts
    flash.each do |level, message|
      bootstrap_level = (level.to_sym == :error) ? :danger : level
      yield level, message, bootstrap_level if message
    end
    nil
  end
end
