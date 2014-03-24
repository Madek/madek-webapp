class API::MediaResourcesRepresenter < API::RepresenterBase

  # property :total_count

  link :self do 
     api_media_resources_path(@represented.query_params) 
  end

  link 'madek:media_resources' do
     api_media_resources_path(@represented.query_params) 
  end

  links :'madek:media_resource' do
    @represented.map do |mr| 
      case mr 
      when MediaEntry
        {href: api_media_entry_path(mr)}
      else
        {href: api_media_resource_path(mr)}
      end
    end 
  end

  link :next do
    next_page=  @represented.query_params["page"].to_i + 1
    if @represented.page(next_page).count > 0
      api_media_resources_path(@represented.query_params.merge(page: next_page)) 
    else
      nil
    end
  end

end
