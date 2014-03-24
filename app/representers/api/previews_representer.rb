class API::PreviewsRepresenter < API::RepresenterBase

  # property :total_count

  link :self do 
     api_previews_path(@represented.query_params) 
  end

  links :'madek:preview' do
    @represented.map do |preview| 
      {href: api_preview_path(preview)}
    end 
  end

  link :next do
    next_page=  @represented.query_params["page"].to_i + 1
    if @represented.page(next_page).count > 0
      api_previews_path(@represented.query_params.merge(page: next_page)) 
    else
      nil
    end
  end



end
