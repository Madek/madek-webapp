class AppAdmin::ZencoderJobsController < AppAdmin::BaseController

  def index
    @zencoder_jobs = ZencoderJob.reorder("created_at DESC").page(params[:page])

    if !params[:fuzzy_search].blank?
      @zencoder_jobs= @zencoder_jobs.fuzzy_search(params[:fuzzy_search])
    end
  end

  def show
    @zencoder_job = ZencoderJob.find params[:id]
  end


end
