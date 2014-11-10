class AppAdmin::ZencoderJobsController < AppAdmin::BaseController

  def index
    @zencoder_jobs = ZencoderJob.only_latest_states.page(params[:page])

    if !params[:fuzzy_search].blank?
      @zencoder_jobs = @zencoder_jobs.fuzzy_search(params[:fuzzy_search])
    end

    if !params[:failed].blank?
      @zencoder_jobs = @zencoder_jobs.failed
    end
  end

  def show
    @zencoder_job = ZencoderJob.find params[:id]
  end

end
