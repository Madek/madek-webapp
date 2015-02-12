class Admin::PreviewsController < AdminController
  def show
    @preview = Preview.find(params[:id])
  end

  def destroy
    preview = Preview.find(params[:id])
    preview.destroy!

    redirect_to admin_media_file_path(preview.media_file), flash: {
      success: 'The preview has been deleted.'
    }
  rescue => e
    redirect_to admin_media_file_path(preview.media_file), flash: {
      error: e.to_s
    }
  end
end
