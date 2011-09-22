class RedClothMadek

  ActionView::Base.sanitized_allowed_tags << 'video'
  ActionView::Base.sanitized_allowed_tags << 'video'
  ActionView::Base.sanitized_allowed_tags << 'source'
  ActionView::Base.sanitized_allowed_attributes << 'controls'
  ActionView::Base.sanitized_allowed_attributes << 'type'
  ActionView::Base.sanitized_allowed_attributes << 'autoplay'

  def initialize
    require 'redcloth'
  end

  def format( text )
    ::RedCloth.new( replace_madek_tags(text) ).to_html
  end

  # Transforms the follwing Textile markups:
  # 
  #   [media=210      | Das Huhn] -> <a href  ="/media_entries/210">Das Huhn</a>
  #   [thumbnail=210  | Das Huhn] -> <img src="/media_entries/210/image" title="Das Huhn"/>
  #   [video=210      | Das Huhn] -> <video src="/media_entries/210/image" title="Das Huhn"/>
  #                                    <a href='/media_entries/210'>(see video)</a>
  #                                  </video>
  #   [include=page] -> Whatever content is on page 'page'
  #
  def replace_madek_tags( text )
    text = media_tag(text)
    text = thumbnail_tag(text)
    text = video_tag(text)
    # The include tag is broken and is therefore skipped
    #text = include_tag(text)
    text
  end

  def media_tag(text)
    text.gsub(/\[\s*media\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/, "<a href='/media_entries/\\1'>\\2</a>")
  end

  def thumbnail_tag(text)
    text.gsub(/\[\s*thumbnail\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/, "<img src='/media_entries/\\1/image' title='\\2'/>")
  end

  # The include tag is broken and is therefore skipped
  def include_tag(text)
    text.gsub(/\[\s*include\s*=\s*(.+)\s*\]/) {
      page = WikiPage.where(:path => $1).first
      unless page.nil?
        wiki_pages_helper = Object.new
        wiki_pages_helper.send :extend, ActionView::Helpers::TextHelper
        #wiki_pages_helper.send :extend, ActionView::Helpers::SanitizeHelper
        wiki_pages_helper.send :extend, Irwi::Helpers::WikiPagesHelper
        ActionController::Base.helpers.sanitize(wiki_pages_helper.auto_link( Irwi.config.formatter.format( wiki_pages_helper.wiki_linkify( page.content ) ) ))
      else
        return "Page '#{$1}' does not exist."
      end
    }

  end

  def video_tag(text)
    text.gsub(/\[\s*video\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/) { 
      "<video src='/media_entries/#{$1}/image' title='#{$2}'>" +
        "<a href='/media_entries/#{$1}'>(see '#{$2}' Video)</a>" +
      "</video>"
    }
  end
  
end

