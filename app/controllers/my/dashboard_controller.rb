class My::DashboardController < MyController

  # "index" action
  def dashboard
    respond_to do |format|
      format.html { render locals: { lget: @get } }
      format.json { respond_with @get }
    end
  end

  # "show" actions
  def dashboard_section
    section_name = params[:section].to_sym

    unless SECTIONS[section_name]
      raise ActionController::RoutingError.new(404), 'No such dashboard section!'
    end

    get = Presenters::Users::UserDashboard.new(
      current_user,
      user_scopes_for_dashboard(current_user),
      list_conf: resource_list_params)

    render 'dashboard_section',
           locals: {
             section: @sections[section_name],
             lget: get
           }
  end
end
