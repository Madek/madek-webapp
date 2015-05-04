module ApplicationHelper
  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end

  def link_active?(link)
    request.path.index(link) == 0
  end

  def ar_collection_proxy?(val)
    val.class < ActiveRecord::Associations::CollectionProxy
  end

  module_function :ar_collection_proxy?
end
