class PreviewsController < ApplicationController

  def show
    # NOTE: see PreviewPolicy (permissions "inherited" from related MediaEntry!)
    preview = get_authorized_resource
    send_file(preview.file_path, type: preview.content_type, disposition: 'inline')
  end

end
