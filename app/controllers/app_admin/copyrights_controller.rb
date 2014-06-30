class AppAdmin::CopyrightsController < AppAdmin::BaseController

  def index
    @copyright_roots = Copyright.where(parent_id: nil)
  end

  def new
    @copyright = Copyright.new params[:copyright]
  end

  def update
    begin
      @copyright = Copyright.find(params[:id])
      if params[:copyright][:parent_id] == "NULL"
        params[:copyright].delete :parent_id
        @copyright.parent_id = nil
        @copyright.save!
      end
      @copyright.update_attributes!(copyright_params)
      redirect_to app_admin_copyright_path(@copyright), flash: {success: "The copyright has been updated."}
    rescue => e
      redirect_to edit_app_admin_copyright_path(@copyright), flash: {error: e.to_s}
    end
  end

  def create
    begin
      if params[:copyright][:parent_id] == "NULL"
        params[:copyright].delete :parent_id
      end
      @copyright = Copyright.create!(copyright_params)
      redirect_to app_admin_copyright_path(@copyright), flash: {success: "A new copyright has been created."}
    rescue => e
      redirect_to new_app_admin_copyright_path(@copyright),flash: {error: e.to_s}
    end
  end

  def show
    @copyright = Copyright.find params[:id]
  end

  def edit
    @copyright = Copyright.find params[:id]
  end

  def destroy
    begin
      @copyright = Copyright.find params[:id]
      @copyright.destroy
      redirect_to app_admin_copyrights_path, flash: {success: "The Copyright has been deleted."}
    rescue => e
      redirect_to :back, flash: {error: e.to_s}
    end
  end

  private

  def copyright_params
    params.require(:copyright).permit(:label, :is_default, :is_custom, :parent_id)
  end

end
