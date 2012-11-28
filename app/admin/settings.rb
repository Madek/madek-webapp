ActiveAdmin.register_page "Settings" do
  menu :label => "Instance Settings", :parent => "Settings"

  content do
    columns do
      column do
        panel "Settings" do
          render :partial => "admin/settings/settings"
        end
      end
    end
  end

  page_action :update, :method => :post do
    params[:settings][:authentication_systems] = Array(params[:settings][:authentication_systems]).map{|x| x.to_sym} if params[:settings][:authentication_systems]
    params[:settings].each_pair do |k,v|
      AppSettings.send("#{k}=", v)
    end
    flash[:notice] = "Updated"

    redirect_to admin_settings_path
  end  

end
