module ActiveLayoutHelper

  def active_layout
    if params[:layout] == "miniature"
      "miniature"
    elsif params[:layout] == "list"
      "list"
    elsif params[:layout] == "grid"
      "grid"
    elsif @media_set and @media_set.settings[:layout]
      @media_set.settings[:layout].to_s
    else 
      nil
    end
  end

end