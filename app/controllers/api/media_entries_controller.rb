class Api::MediaEntriesController < ApiController

  def show
    if Concerns::CustomUrls::UUID_MATCHER.match params[:id]
      @media_resource= MediaResource.find(params[:id])
      unless @api_application.authorized?(:view,@media_resource)
        raise ActiveRecord::RecordNotFound.new(@media_resource) 
      end
      if @media_resource.is_a? MediaEntry
        render json: API::MediaEntryRepresenter.new(@media_resource).as_json.to_json
        response.headers["Content-Type"] = "application/hal+json; charset=utf-8"
      else 
        redirect_to api_media_resource_path(@media_resource.id)
        return
      end
    else 
      redirect_to api_media_resource_path(params[:id])
      return
    end
  end

  def content_stream
    @media_entry= MediaEntry.find(params[:id])
    unless @api_application.authorized?(:download,@media_entry)
      raise ::NotAuthorized.new(@media_entry) 
    end
    @media_file= @media_entry.media_file
    send_file @media_file.file_storage_location.to_s,  
      type: @media_file.content_type,
      disposition: 'inline'
  end

end
