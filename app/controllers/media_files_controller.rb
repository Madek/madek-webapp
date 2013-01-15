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
      if Rails.env.production?
        fixed_send_file @media_file.file_storage_location.to_s, {:type => @media_file.content_type, :filename => @media_file.filename, :disposition => 'attachment'}
      else
        send_file @media_file.file_storage_location.to_s, {:type => @media_file.content_type, :filename => @media_file.filename, :disposition => 'attachment'}
      end
    end
  end

  # send_file() as above seems to be broken in Rails 3.1.3 and onwards?
  # The Rack::Sendfile#call method never seems to receive a body that respons to :to_path, even though it SHOULD,
  # therefore Sendfile is never triggered (!!), that's why we need this hacked Sendfile header implementation
  def fixed_send_file(path, options = {})
    headers["Content-Type"] = options[:type]
    headers["Content-Disposition"] = "attachment; filename=\"#{options[:filename]}\""
    headers["X-Sendfile"] = path.to_s
    headers["Content-Length"] = '0'
    render :nothing => true
  end

end
