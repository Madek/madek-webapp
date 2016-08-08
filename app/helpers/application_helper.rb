module ApplicationHelper
  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end

  def link_active?(link, deep: false)
    unless deep
      request.path.index(link) == 0
    else
      request.path == link
    end
  end

end
