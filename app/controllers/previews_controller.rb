class PreviewsController < ApplicationController
  include Concerns::ServeFiles

  def show
    # NOTE: see PreviewPolicy (permissions "inherited" from related MediaEntry!)
    preview = get_authorized_resource

    # Send 304 if Preview did not change.
    # NOTE: could be optimized but it's tricky because of the permissions.
    # It's safe now because we do this a) after authorization b) with public=false
    if stale?(preview, public: false, template: false)
      serve_file(preview.file_path, content_type: preview.content_type)
    end
  end
end
