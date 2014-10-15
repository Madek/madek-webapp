class AppAdmin::FilterSetsController < AppAdmin::BaseController

  def index
    @filter_sets = MediaResource.filter_sets
  end

  def destroy
    @filter_set = MediaResource.find(params[:id])
    @filter_set.destroy!

    redirect_to app_admin_filter_sets_url, flash: {success: "The Filter Set has been deleted."}
  rescue => e
    redirect_to app_admin_filter_sets_url, flash: {error: e.to_s}
  end

end
