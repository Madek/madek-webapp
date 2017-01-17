class MediaFilesController < ApplicationController
  # NOTE: This is *also* used by ZENCODER integration, be careful!
  #       Extracted methods are just for clarity.

  include Concerns::ServeFiles

  def show
    if access_hash_param?
      download_by_access_hash
    else
      download_by_user_permissions
    end
  end

  private

  def download_by_user_permissions
    media_file = MediaFile.find_by!(id: id_param)
    auth_authorize(media_file)
    serve_file(
      media_file.original_store_location,
      content_type: get_content_type(media_file),
      filename: media_file.filename)
  end

  def download_by_access_hash
    skip_authorization # do custom auth because there is no logged in user
    access_hash_param = params.require(:access_hash)
    media_file = MediaFile.find_by!(id: id_param, access_hash: access_hash_param)
    serve_file(
      media_file.original_store_location,
      content_type: get_content_type(media_file),
      filename: media_file.filename)
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

  def access_hash_param?
    params.permit(:access_hash).fetch(:access_hash, nil).present?
  end
end
