class AppAdmin::PreviewsController < AppAdmin::BaseController
  def show
    @preview = Preview.find params[:id]
  end
end
