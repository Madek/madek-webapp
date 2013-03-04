class PreviewsController < ApplicationController

  def show

    @preview = Preview.find params[:id]

    # for now, only video and audio previews use this route
     
    # CONFIGURED_FOR_VIDEO_STREAMING
    #
    # This apache_url_for_symlink points to a symlink to the actual
    # file, so that Apache serves it. This lets us support seeking, partial
    # content (HTTP status code 206) and request ranges without any additional
    # work.

    if ENV['CONFIGURED_FOR_VIDEO_STREAMING'].to_i != 0 
      @preview.create_symlink
      redirect_to @preview.apache_url_for_symlink, status: 307
    else
      send (Rails.env.production? ? :fixed_send_file : :send_file), 
        @preview.full_path, type: @preview.content_type, 
        filename: @preview.filename, disposition: 'attachment'
    end

  end

  # TODO same method as in MediaFilesController, put it in a helper once 
  # we know it works for this case
  #
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
