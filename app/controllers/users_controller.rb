class UsersController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  skip_before_action :verify_usage_terms_accepted!, only: [:accepted_usage_terms]
  def accepted_usage_terms
    authorize current_user, :logged_in?
    usage_term_id = params.require(:usage_term_id)
    return_to = params.fetch(:return_to).presence || my_dashboard_path

    current_user.update_attributes!(
      accepted_usage_terms_id: UsageTerms.find(usage_term_id).id)

    flash.keep
    respond_with(nil, location: return_to)
  end

  private

  def search_params
    [params[:search_term], params[:search_also_in_person]]
  end

end
