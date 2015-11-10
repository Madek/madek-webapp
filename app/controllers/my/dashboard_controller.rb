class My::DashboardController < MyController

  # "index" action
  def dashboard
    respond_with @get
  end

  # "show" actions
  def dashboard_section
    section_name = params[:section].to_sym

    unless SECTIONS[section_name]
      raise ActionController::RoutingError.new(404), 'No such dashboard section!'
    end

    get = Presenters::Users::UserDashboard.new(current_user,
                                               list_conf: resource_list_params)

    render 'dashboard_section',
           locals: {
             section: @sections[section_name],
             get: get
           }
  end
end
