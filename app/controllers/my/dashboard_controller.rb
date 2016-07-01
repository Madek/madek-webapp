class My::DashboardController < MyController

  # "index" action
  def dashboard
    respond_to do |format|
      format.html { respond_with @get }
      format.json { respond_with @get }
    end
  end

  # "show" actions
  def dashboard_section
    unless current_section
      raise ActionController::RoutingError.new(404), 'No such dashboard section!'
    end

    get = Presenters::Users::UserDashboard.new(
      current_user,
      user_scopes_for_dashboard(current_user),
      Presenters::Users::DashboardHeader.new(nil),
      list_conf: \
        resource_list_params(params,
                             current_section[:allowed_filter_params]))

    render 'dashboard_section',
           locals: {
             section: current_section,
             get: get
           }
  end
end
