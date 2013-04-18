class AppAdmin::PreviewsController < AppAdmin::BaseController
  def show
    @preview = Preview.find params[:id]
  end

  def destroy
    begin 
      @preview = Preview.find params[:id]
      @preview.destroy
      redirect_to :back, flash: {success: "The Review has been deleted."}
    rescue  => e
      redirect_to :back, flash: {error: e.to_s} 
    end
  end
end
