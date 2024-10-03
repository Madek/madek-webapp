class MediaFilesController < ApplicationController
  # NOTE: This is *also* used by ZENCODER integration, be careful!
  #       Extracted methods are just for clarity.

  include ServeFiles

  #############################################################
  # Check if associated resource is soft-deleted and thus sort
  # of does not exist (excluded in default scope).
  before_action do
    @media_file = MediaFile.find(params.require(:id))
    unless MediaEntry.unscoped.not_deleted.find_by_id(@media_file.media_entry_id)
      raise ActiveRecord::RecordNotFound, "MediaFile not found"
    end
  end
  #############################################################

  def show
    if access_token_param
      download_by_access_token
    else
      download_by_user_permissions
    end
  end

  private

  def download_by_user_permissions
    auth_authorize(@media_file)
    serve_file(
      @media_file.original_store_location,
      content_type: get_content_type(@media_file),
      filename: @media_file.filename)
  end

  def download_by_access_token
    skip_authorization # do custom auth because there is no logged in user
    validate_access_token_param!
    serve_file(@media_file.original_store_location,
               content_type: get_content_type(@media_file),
               filename: @media_file.filename)
  end

  def get_content_type(media_file)
    if media_file.extension == 'pdf'
      'application/pdf'
    elsif media_file.content_type.include?('html')
      'application/octet-stream' # don't interpret as HTML!
    else
      media_file.content_type
    end
  end

  def id_param
    params.require(:id)
  end

  def access_token_param
    params.permit(:access_token).fetch(:access_token) do
      # Using `access_hash` fallback only for backwards compatibility
      # with old zencoder jobs.
      params.permit(:access_hash).fetch(:access_hash, nil)
    end.presence
  end

  def validate_access_token_param!
    zj = ZencoderJob.find_by!(access_token: access_token_param,
                              media_file_id: @media_file.id)
    unless zj.access_token_valid_until > Time.now 
      raise "Access token expired"
    end
  end
end
