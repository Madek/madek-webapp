class Admin::MediaFilesController < AdminController
  def show
    @media_file = MediaFile.find(params[:id])
    @zencoder_jobs = @media_file.zencoder_jobs if @media_file.audio_video?
  end
end
