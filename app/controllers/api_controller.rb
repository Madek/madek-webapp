class ApiController < ActionController::Base

  before_action :require_authentication!, except: [:show]

  def initialize_api_application
    @api_id,@api_secret= ActionController::HttpAuthentication::Basic.user_name_and_password(request) rescue [nil,nil]
    @api_id ||= request.headers['HTTP_API_ID']
    @api_secret ||= request.headers['HTTP_API_SECRET']
    @api_application= API::Application.find_by(id: @api_id) 
  end

  def authenticated? 
    initialize_api_application
    (! @api_application.nil?) and @api_application.secret == @api_secret
  end

  def require_authentication!
    unless authenticated? 
      render json: {error: "authentication required"}, status: 401 
      return
    end
  end

  class Index
    def initialize api_controller
      @api_controller = api_controller
    end

    def welcome_message
      "Welcome to the MAdeK API!"
    end

    def authenticated
      @api_controller.authenticated?
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


