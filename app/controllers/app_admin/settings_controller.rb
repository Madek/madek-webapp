class AppAdmin::SettingsController < AppAdmin::BaseController
  before_action :settings

  def index
  end

  def edit
    @field = params[:id]
  end

  def show
  end

  def update
    begin
      if yaml_footer_links = params.try(:[], :app_settings_extra).try(:[], :yaml_footer_links)
        footer_links = YAML.load yaml_footer_links
        @settings.update_attribute(:footer_links, footer_links)
      else
        @settings.update_attributes(settings_params)
      end
      redirect_to app_admin_settings_path, flash: {success: "The settings have been saved successfuly."}
    rescue => e
      redirect_to app_admin_settings_path, flash: {error: e.to_s}
    end
  end

  private
  def settings
    @settings = @app_settings
  end

  def settings_params
    params.require(:app_settings).permit!
  end

end
