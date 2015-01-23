module AdminHelper
  def navbar_item(text, path)
    content_tag :li, class: ('active' if current_page?(path)) do
      link_to text, path
    end
  end
end
