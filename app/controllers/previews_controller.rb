class PreviewsController < ApplicationController

  def show
    @preview = Preview.find params[:id]

    send (Settings.use_x_sendfile ? :fixed_send_file : :send_file), 
      @preview.full_path, type: @preview.content_type, 
      filename: @preview.filename, disposition: 'attachment'
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
