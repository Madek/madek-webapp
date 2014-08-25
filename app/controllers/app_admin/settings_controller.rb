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
      flash_message = {success: "The settings have been updated."}
      if yaml_footer_links = params.try(:[], :app_settings_extra).try(:[], :yaml_footer_links)
        footer_links = YAML.load yaml_footer_links
        @settings.update_attribute(:footer_links, footer_links)
      else
        @settings.assign_attributes(settings_params)
        if special_sets_params? && !@settings.changed?
          flash_message = {notice: "The special sets have not been updated."}
        end
        @settings.save
      end
      redirect_to app_admin_settings_path, flash: flash_message
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

  def special_sets_params?
    settings_params.keys == %w{featured_set_id teaser_set_id catalog_set_id}
  end

end
