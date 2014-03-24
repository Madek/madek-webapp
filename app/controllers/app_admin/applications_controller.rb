class AppAdmin::ApplicationsController < AppAdmin::BaseController

  def allowed_api_application_params
    params.require(:api_application).permit(:id,:description,:user)
  end

  def user_by_login_param
    User.find_by login: allowed_api_application_params[:user].match(/\[(.*)\]/)[1] rescue nil
  end

  def index
    @applications = ::API::Application.all.page(params[:page])
  end

  def new 
    @application= ::API::Application.new params[:api_application].try(:permit,:id) || {}
  end

  def create
    begin
      @application= ::API::Application.create! allowed_api_application_params.merge({user: user_by_login_param})
      redirect_to app_admin_application_path(@application), flash: {success: "A new application has been created"}
    rescue => e
      redirect_to new_app_admin_application_path(api_application: params[:api_application]), flash: {error: e.to_s}
    end
  end

  def show
    @application= API::Application.find params[:id]
  end


  def destroy 
    begin 
      ::API::Application.destroy(params[:id])
      redirect_to app_admin_applications_path, flash: {success: "The application has been destroyed!"}
    rescue => e
      redirect_to app_admin_applications_path, flash: {error: e.to_s}
    end
  end



end
