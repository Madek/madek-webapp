class ApiController < ActionController::Base

  before_action :authenticate! 

  def initialize_api_application
    @api_id,@api_secret= ActionController::HttpAuthentication::Basic.user_name_and_password(request) rescue [nil,nil]
    @api_application= API::Application.find_by(id: @api_id) 
  end

  def authenticated? 
    (! @api_application.nil?) and @api_application.secret == @api_secret
  end

  def authenticate!
    require_authentication! unless  params["controller"] == "api" and params["action"] == "show" 
  end

  def require_authentication!
    initialize_api_application
    send_not_authorized_and_return unless authenticated?
  end

  def send_not_authorized_and_return
    response.headers["WWW-Authenticate"]='Basic realm="Provide application id and secret to access the Madek API."'
    render json: {error: "authentication required"}, status: 401 
    return
  end

  class Index
    def initialize api_controller
      @api_controller = api_controller
    end

    def welcome_message
      "Welcome to the MAdeK API!"
    end
  end

  def show
    respond_to do |format|
      format.json do
        render json: API::IndexRepresenter.new(Index.new(self)).as_json 
      end
      format.html do
      end
    end
  end

end


