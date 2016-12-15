class PreviewsController < ApplicationController
  include Concerns::ServeFiles

  def show
    # NOTE: see PreviewPolicy (permissions "inherited" from related MediaEntry!)
    preview = get_authorized_resource

    # Send 304 if Preview did not change.
    # NOTE: could be optimized but it's tricky because of the permissions.
    # It's safe now because we do this a) after authorization b) with public=false
    if stale?(preview, public: false, template: false)
      serve_file(
        preview.file_path,
        content_type: preview.content_type,
        filename: download_filename(preview))
    end
  end

  private

  def download_filename(preview)
    media_file = preview.media_file
    return unless (media_file and media_file.filename)

    "#{media_file.filename}#{size(preview)}#{extension(preview)}"
  end

  def size(preview)
    return '' unless (preview.width and preview.height)

    # for example '.640x480'
    ".#{preview.width}x#{preview.height}"
  end

  def extension(preview)
    File.extname(preview.filename)
  end
end
