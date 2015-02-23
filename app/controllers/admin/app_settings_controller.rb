class Admin::AppSettingsController < AdminController

  before_action :set_app_settings

  def index
  end

  def edit
    @field = params[:id]
  end

  def update
    if sitemap = params.try(:[], :app_setting).try(:[], :sitemap)
      params[:app_setting][:sitemap] = YAML.load sitemap
    end
    @app_settings.assign_attributes(app_setting_params)
    @app_settings.save
    redirect_to admin_app_settings_path, flash: {
      success: 'Setting has been updated.'
    }
  rescue => e
    redirect_to admin_app_settings_path, flash: { error: e.to_s }
  end

  private

  def set_app_settings
    @app_settings = AppSetting.first
  end

  def app_setting_params
    params.require(:app_setting).permit!
  end
end
