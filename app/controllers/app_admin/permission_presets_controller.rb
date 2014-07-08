class AppAdmin::PermissionPresetsController < AppAdmin::BaseController
  def index
    begin 
      @permission_presets = PermissionPreset.page(params[:page])
    rescue Exception => e
      @permission_presets = PermissionPreset.page(params[:page])
      @error_message= e.to_s
    end

  end

  def new
    @permission_preset = PermissionPreset.new params[:permission_preset]
  end

  def update
    begin
      @permission_preset = PermissionPreset.find(params[:id])
      @permission_preset.update_attributes! permission_preset_params
      redirect_to app_admin_permission_preset_path(@permission_preset), flash: {success: "The permission_preset has been updated."}
    rescue => e
      redirect_to edit_app_admin_permission_preset_path(@permission_preset), flash: {error: e.to_s}
    end
  end

  def create
    begin
      @permission_preset = PermissionPreset.create! permission_preset_params
      redirect_to app_admin_permission_preset_path(@permission_preset), flash: {success: "A new permission_preset has been created."}
    rescue => e
      redirect_to new_app_admin_permission_preset_path(@permission_preset),flash: {error: e.to_s}
    end
  end

  def show
    @permission_preset = PermissionPreset.find params[:id]
  end

  def edit
    @permission_preset = PermissionPreset.find params[:id]
  end

  def destroy
      @permission_preset = PermissionPreset.find params[:id]
      @permission_preset.destroy
      redirect_to app_admin_permission_presets_path, flash: {success: "The PermissionPreset has been deleted."}
  end

  def move_up
    @permission_preset = PermissionPreset.find(params[:id])
    @permission_preset.move_higher
    redirect_to app_admin_permission_presets_path
  end

  def move_down
    @permission_preset = PermissionPreset.find(params[:id])
    @permission_preset.move_lower
    redirect_to app_admin_permission_presets_path
  end

  private

  def permission_preset_params
    params.require(:permission_preset).permit!
  end
end
