class PreviewsController < ApplicationController

  def show
    # NOTE: see PreviewPolicy (permissions "inherited" from related MediaEntry!)
    preview = get_authorized_resource

    # Send 304 if Preview did not change.
    # NOTE: could be optimized but it's tricky because of the permissions.
    # It's safe now because we do this a) after authorization b) with public=false
    if stale?(preview, public: false, template: false)
      begin
      send_file(
        preview.file_path,
        type: preview.content_type,
        disposition: 'inline')
      rescue ActionController::MissingFile => e
        # TODO remove this hack
        logger.warn "Preview #{preview.file_path} not found"
        send_data ""
      end
    end
  end

end
