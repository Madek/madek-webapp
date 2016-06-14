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

  def show_for_keyword
    # response is either a redirect (authorization is performed there) or 404
    skip_authorization

    media_entry_with_media_file = \
      MediaEntry
      .viewable_by_user_or_public(current_user)
      .joins(:media_file)
      .joins(:meta_data)
      .joins('INNER JOIN meta_data_keywords ' \
             'ON meta_data.id = meta_data_keywords.meta_datum_id')
      .where(meta_data_keywords: { keyword_id: keyword_id_param })
      .where(media_files: { media_type: 'image' })
      .first

    if media_entry_with_media_file
      preview = \
        media_entry_with_media_file.media_file.preview(preview_size_param)
      redirect_to preview_path(preview)
    else
      render status: :not_found
    end
  end

  private

  def keyword_id_param
    params.require(:keyword_id)
  end

  def preview_size_param
    params.require(:preview_size)
  end

end
