class RedClothMadek

  ActionView::Base.sanitized_allowed_tags << 'video'

  def initialize
    require 'redcloth'
  end

  def format( text )
    ::RedCloth.new( replace_madek_tags(text) ).to_html
  end

  # Transforms the follwing Textile markups:
  # 
  #   [media=210      | Das Huhn] -> <a href  ="/media_entries/210">Das Huhn</a>
  #   [screenshot=210 | Das Huhn] -> <img src="/media_entries/210/image" title="Das Huhn"/>
  #   [video=210      | Das Huhn] -> <video src="/media_entries/210/image" title="Das Huhn"/>
  #                                    <a href='/media_entries/210'>(see video)</a>
  #                                  </video>
  #
  def replace_madek_tags( text )

    # unfortunately having multiple matches in gsub doesn't seem to work, therefore
    # we fall back to $1 $2
    #
    text.gsub(/\[\s*media\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/, "<a href='/media_entries/\\1'>\\2</a>").
         gsub(/\[\s*screenshot\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/, "<img src='/media_entries/\\1/image' title='\\2'/>").
         gsub(/\[\s*video\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/) { |number,title|
           "<video src='/media_entries/\\1/image' title='\\2'>" +
             "<a href='/media_entries/\\1'>(see '\\2' Video)</a>" +
           "</video>"  }
  end

end

