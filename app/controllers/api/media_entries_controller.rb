class Api::MediaEntriesController < ApiController

  def show
    if Concerns::CustomUrls::UUID_MATCHER.match params[:id]
      @media_resource= MediaResource.find(params[:id])
      if @media_resource.is_a? MediaEntry
        render json: API::MediaEntryRepresenter.new(@media_resource).as_json.to_json
      else 
        redirect_to api_media_resource_path(@media_resource.id)
        return
      end
    else 
      redirect_to api_media_resource_path(params[:id])
      return
    end
  end

  def data_stream
    @media_entry= MediaEntry.find(params[:id])
    @media_file= @media_entry.media_file
    send_file @media_file.file_storage_location.to_s,  
      type: @media_file.content_type,
      disposition: 'inline'
  end

end
