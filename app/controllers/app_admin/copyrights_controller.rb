class AppAdmin::CopyrightsController < AppAdmin::BaseController

  before_action :labels_for_select, only: [:edit, :new]

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

  def move_up
    @copyright = Copyright.find(params[:id])
    @copyright.move_higher
    redirect_to app_admin_copyrights_path
  end

  def move_down
    @copyright = Copyright.find(params[:id])
    @copyright.move_lower
    redirect_to app_admin_copyrights_path
  end

  def labels_for_select
    @copyrights = build_labels(Copyright.where(parent_id: nil), 0)
    @disabled = build_labels(Copyright.where(id: params[:id]), nil)
  end
  
  def build_labels(copyright, depth)
    result = []
    copyright.each do |copy|
      if depth
        result << ["#{'-' * depth} #{copy.label}", copy.id]
        result += build_labels(copy.children, depth+1)
      else
        result += [copy.label, copy.id]
        result += build_labels(copy.children, nil)
      end
    end
    result
  end

  private

  def copyright_params
    params.require(:copyright).permit(:label, :is_default, :is_custom, :parent_id)
  end

end
