class Admin::PreviewsController < AdminController
  def show
    @preview = Preview.find(params[:id])
  end

  def destroy
    preview = Preview.find(params[:id])
    preview.destroy!

    redirect_to admin_media_file_path(preview.media_file), flash: {
      success: ['The preview has been deleted.']
    }
  end

  def raw_file
    file_path = Preview.find(params[:preview_id]).file_path
    return unless file_path
    send_file file_path,
              type: 'image',
              disposition: 'inline'
  end
end
