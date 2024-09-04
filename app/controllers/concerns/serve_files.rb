module ServeFiles
  extend ActiveSupport::Concern

  # serves files from filesystem, support param to force download

  def serve_file(file_path, filename: nil, content_type: nil)
    disposition = download_param ? 'attachment' : 'inline'

    begin
      send_file(
        file_path,
        filename: filename,
        type: content_type,
        disposition: disposition
      )
    rescue ActionController::MissingFile => e
      # don't spam the log with stacktraces of "file not found"!
      logger.error "File missing! - #{e.message}"
      # it our fault if we found a filepath in DB but its missing in file system!
      head 500 # respond with empty server error.
    end
  end

  private

  def download_param
    params.permit(:download).keys.include?('download')
  end

end
