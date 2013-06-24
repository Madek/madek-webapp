class AppAdmin::SettingsController < AppAdmin::BaseController 

  def edit
    @settings = @app_settings 
  end

  def show
    @settings = @app_settings
  end

  def update
    begin
      footer_links = YAML.load params[:app_settings_extra][:yaml_footer_links]
      AppSettings.first.update_attributes! \
        Hash[params[:app_settings].map{|k,v| v.blank? ? [k,nil] : [k,v]}] \
          .merge("footer_links" => footer_links)
      redirect_to edit_app_admin_settings_path, flash: {success: "The settings have been saved successfuly."}
    rescue => e
      redirect_to edit_app_admin_settings_path, flash: {error: e.to_s}
    end
  end

end
