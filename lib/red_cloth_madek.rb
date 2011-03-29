class RedClothMadek

  def initialize
    require 'redcloth'
  end

  def format( text )
    ::RedCloth.new( replace_madek_tags(text) ).to_html
  end

  # Transforms the follwing Textile markup to a link to a medium
  # 
  #    [[media=210 | Das Huhn]]
  #
  def replace_madek_tags( text )

    # unfortunately having multiple matches in gsub doesn't seem to work, therefore
    # we fall back to $1 $2
    #
    text.gsub(/\[\s*media\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/) { |number,txt|

           "<a href='/media_entries/#{$1}'>#{h($2)}</a>"                 }.

         gsub(/\[\s*screenshot\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/) { |number,title|

           "<img src='/media_entries/#{$1}/image' title='#{h($2)}'/>"    }.

         gsub(/\[\s*video\s*=\s*(\d+)\s*\|\s*([^\]]+)\s*\]/) { |number,title|
           "<video src='/media_entries/#{$1}/image' title='#{h($2)}'>" +
             "<a href='/media_entries/#{$1}'>(see video)</a>" +
           "</video>"  }
  end

end

