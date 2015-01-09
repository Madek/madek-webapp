# app/helpers/application_helper.rb

module ApplicationHelper
  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end

  # layout render shortcut
  def partial(name, config = nil, &block)
    if block_given?
      render layout: name, locals: config, &block
    else
      render layout: name, locals: config
    end
  end

end
