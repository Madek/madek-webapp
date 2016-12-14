class UsersController < ApplicationController
  include Concerns::JSONSearch
  include Concerns::RedirectBackOr

  def index
    get_and_respond_with_json
  end

  # NOTE: skip strictly needed - this is the only allowed action if verify fails
  skip_before_action :verify_usage_terms_accepted!, only: [:accepted_usage_terms]
  # NOTE: skip only because CSRF-Token has edge cases and it breaks app for users
  skip_before_action :verify_authenticity_token, only: [:accepted_usage_terms]
  def accepted_usage_terms
    auth_authorize current_user, :logged_in?
    usage_term_id = params.require(:usage_term_id)
    return_to = params.fetch(:return_to).presence || my_dashboard_path

    current_user.update_attributes!(
      accepted_usage_terms_id: UsageTerms.find(usage_term_id).id)

    flash.keep
    respond_with(nil, location: return_to)
  end

  def toggle_uberadmin
    authorize(current_user)
    if !session[:uberadmin_mode]
      session[:uberadmin_mode] = true
      redirect_back_or my_dashboard_path, success: 'Admin-Modus aktiviert!'
    else
      session[:uberadmin_mode] = false
      redirect_back_or my_dashboard_path, success: 'Admin-Modus deaktiviert!'
    end
  end

  private

  def search_params
    [params[:search_term], params[:search_also_in_person]]
  end

end
