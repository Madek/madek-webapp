class MediaFilesController < ApplicationController

  skip_before_filter :login_required

  # The +show+ method only actually shows the requested media file if the request includes a
  # hash that is set on the media file. This is useful when we want to e.g. refer external
  # services such as Zencoder to one of our files via HTTP.
  def show
    @media_file = MediaFile.where(:access_hash => params[:access_hash]).find_by_id(params[:id])
    if @media_file.nil?
      render :text => 'Media file not found. Direct media access is only possible on a request-by-request basis using an access hash. Do you have a valid access hash? If so, append it to the query string: ?access_hash=123-456-789', :status => :not_found
    else
      send_file @media_file.file_storage_location.to_s, {:type => @media_file.content_type, :filename => @media_file.filename, :disposition => 'attachment'}
    end
  end

end
