class ApiTokensController < ApplicationController
  include Concerns::ResourceListParams
  extend ActiveSupport::Concern

  before_action do
    auth_authorize :dashboard, :logged_in?
  end

  def new_api_token
    given_props = params.permit([:description, :callback_url])
    disallow_insecure_http(given_props['callback_url'])
    token = ApiToken.new(user_id: current_user.id)
    @get = presenterify_api_token(token, :new, given_props)
    respond_with(@get, layout: 'application', template: 'my/new_api_token')
  end

  def create_api_token
    attrs = token_params([:description])
    callback_url = params.permit(:callback_url).fetch(:callback_url, nil)
    disallow_insecure_http(callback_url)

    token = ApiToken.create(user_id: current_user.id)
    token.update_attributes!(attrs) && token.reload

    # NOTE: don't use `respond_with`! we render content in reponse to POST,
    #       which goes against the convention (normally a redirect to GET)
    @get = presenterify_api_token(token, :show, callback_url)
    respond_to do |format|
      format.html do
        render(status: 201, layout: 'application', template: 'my/create_api_token')
      end
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

  def presenterify_api_token(api_token, action_name = :index, *params)
    "Presenters::ApiTokens::#{"ApiToken_#{action_name}".classify}"
      .constantize
      .new(api_token, current_user, *params)
  end

  def token_params(props)
    params.permit(api_token: props).fetch(:api_token, {})
      .map { |k, v| [k, v.presence] }.to_h
  end

  def disallow_insecure_http(url)
    return if url.nil? or Rails.env == 'development'
    if URI.parse(url).scheme == 'http'
      raise Errors::InvalidParameterValue, "Insecure URL `#{url}`!"
    end
  end
end
