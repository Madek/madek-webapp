class AppAdmin::ZencoderJobsController < AppAdmin::BaseController

  def index
    @zencoder_jobs = ZencoderJob.reorder("created_at DESC").page(params[:page])
  end

  def show
    @zencoder_job = ZencoderJob.find params[:id]
  end


end
