module Concerns
  module UserApiTokens
    extend ActiveSupport::Concern

    def new_api_token
      token = ApiToken.new(user_id: current_user.id)
      @get = presenterify_api_token(token, :new)
      respond_with(@get, layout: 'application')
    end

    def create_api_token
      attrs = token_params([:description])

      token = ApiToken.create(user_id: current_user.id)
      token.update_attributes!(attrs) && token.reload

      # NOTE: don't use `respond_with`! we render content in reponse to POST,
      #       which goes against the convention (normally a redirect to GET)
      @get = presenterify_api_token(token, :show)
      respond_to do |format|
        format.html { render status: 201, layout: 'application' }
        format.json { render status: 201, json: @get.as_json }
      end
    end

    def update_api_token
      props = [:revoked, :description]
      attrs = params.permit(api_token: props).fetch(:api_token, {})
      token = ApiToken.find(params.require(:id))
      auth_authorize(token)
      token.update_attributes!(attrs) && token.reload

      @get = presenterify_api_token(token)
      respond_with(@get, location: my_dashboard_section_path(:tokens))
    end

    private

    def presenterify_api_token(api_token, action_name = :index)
      "Presenters::ApiTokens::#{"ApiToken_#{action_name}".classify}"
        .constantize
        .new(api_token, current_user)
    end

    def token_params(props)
      params.permit(api_token: props).fetch(:api_token, {})
        .map { |k, v| [k, v.presence] }.to_h
    end

  end
end
