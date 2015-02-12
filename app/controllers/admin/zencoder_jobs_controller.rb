class Admin::ZencoderJobsController < AdminController
  def show
    @zencoder_job = ZencoderJob.find(params[:id])
  end
end
