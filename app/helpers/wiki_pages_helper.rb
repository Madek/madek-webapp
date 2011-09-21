module WikiPagesHelper
  acts_as_wiki_pages_helper

  def wiki_page_style
   stylesheet_link_tag "wiki"
  end

end
