class PreviewsController < ApplicationController
  include ServeFiles

  #################################################################
  # Check if associated resource is soft-deleted and thus sort
  # of does not exist (excluded in default scope).
  before_action do
    p = Preview.find(params.require(:id))
    me_id = p.media_file.media_entry_id
    unless MediaEntry.unscoped.not_deleted.find_by_id(me_id)
      raise ActiveRecord::RecordNotFound, "Preview not found"
    end
  end
  #################################################################

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

  def hls_file
    preview = get_authorized_resource
    raise ActiveRecord::RecordNotFound unless preview.hls?

    path = safe_hls_file(preview, hls_relative_path)
    if File.extname(path) == '.m3u8'
      body = HlsPackage.append_access_token(File.read(path), params[:accessToken])
      response.headers['Cache-Control'] = 'private, no-cache'
      send_data(
        body,
        type: 'application/vnd.apple.mpegurl',
        disposition: 'inline'
      )
    else
      serve_hls_media(preview, path)
    end
  rescue Errno::ENOENT
    raise ActiveRecord::RecordNotFound
  end

  def hls_package
    preview = get_authorized_resource
    raise ActiveRecord::RecordNotFound unless preview.hls?

    zip = HlsPackage.new(preview.media_file).ensure_zip!
    basename = File.basename(preview.media_file.filename.to_s, '.*')
    basename = 'video' if basename.blank?
    send_file(
      zip,
      filename: "#{basename}-hls.zip",
      type: 'application/zip',
      disposition: 'attachment'
    )
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

  HLS_FILE_EXTENSIONS = %w[.m3u8 .mp4 .m4f].freeze

  def hls_relative_path
    Array(params[:path]).join('/')
  end

  def safe_hls_file(preview, relative)
    raise ActiveRecord::RecordNotFound if relative.blank?
    raise ActiveRecord::RecordNotFound if relative.include?('..') || relative.include?("\0")
    raise ActiveRecord::RecordNotFound if relative.start_with?('/')
    raise ActiveRecord::RecordNotFound unless HLS_FILE_EXTENSIONS.include?(File.extname(relative))

    root = File.realpath(preview.hls_dir)
    candidate = File.join(root, relative)
    raise ActiveRecord::RecordNotFound unless File.file?(candidate)

    real = File.realpath(candidate)
    raise ActiveRecord::RecordNotFound unless real.start_with?(root + File::SEPARATOR)

    real
  end

  def serve_hls_media(preview, path)
    relative = Pathname.new(path).relative_path_from(Pathname.new(File.realpath(preview.hls_dir))).to_s
    env = request.env.dup
    env['PATH_INFO'] = "/#{relative}"
    env['SCRIPT_NAME'] = ''
    status, headers, body = Rack::Files.new(preview.hls_dir).call(env)
    self.status = status
    self.response_body = body
    headers.each { |key, value| response.headers[key] = value }
    return unless download_param

    response.headers['Content-Disposition'] =
      %(attachment; filename="#{File.basename(path)}")
  end
end
