class MediaFilesController < ApplicationController
  def show
    media_file =
      MediaFile.find_by(id: params[:id], access_hash: params[:access_hash])

    authorize media_file

    send_file(
      media_file.original_store_location,
      filename: media_file.filename,
      type: media_file.content_type
    )
  end
end
