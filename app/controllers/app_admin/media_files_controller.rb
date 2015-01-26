class AppAdmin::MediaFilesController < AppAdmin::BaseController
  def index

    @media_files = MediaFile.order("created_at DESC").page(params[:page])

    if !params[:fuzzy_search].blank?
      @media_files= @media_files.fuzzy_search(params[:fuzzy_search])
    end

    if !params[:incomplete_encoded_videos].blank?
      @media_files = @media_files.send(:incomplete_encoded_videos)
    end

    if !params[:only_with_media_entry].blank?
      @media_files = @media_files.joins(:media_entry)
    end


  end

  def show
    @media_file = MediaFile.find params[:id]
    @zencoder_jobs = @media_file.zencoder_jobs.reorder(created_at: :desc, id: :asc)
  end

  def reencode
    begin 
      @media_file = MediaFile.find params[:id]
      @media_file.previews.destroy_all
      if Settings.zencoder.enabled?
        ZencoderJob.create(media_file: @media_file).submit
      else
        raise "Zencoder is not enabled. Check you configuration." 
      end
      redirect_to app_admin_media_file_path(@media_file), flash: {success: "The Zencoder.job has been submitted"}
    rescue => e 
      redirect_to app_admin_media_file_path(@media_file), flash: {error: e}
    end

  end

  def recreate_thumbnails
    begin 
      @media_file= MediaFile.find params[:id]
      @media_file.recreate_image_previews!
      redirect_to app_admin_media_file_path(@media_file), flash: {success: "The thumbnails have been recreated"}
    rescue => e 
      redirect_to app_admin_media_file_path(@media_file), flash: {error: e}
    end
  end

end
