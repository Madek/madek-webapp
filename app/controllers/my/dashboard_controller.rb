class My::DashboardController < MyController

  # "index" action
  def dashboard
    respond_with @get
  end

  # "show" actions
  def dashboard_section
    unless current_section
      raise ActionController::RoutingError.new(404), 'No such dashboard section!'
    end

    respond_with_subsection(
      Presenters::Users::UserDashboard.new(
        current_user,
        user_scopes_for_dashboard(current_user),
        Presenters::Users::DashboardHeader.new(nil),
        list_conf: resource_list_params(
          params, current_section[:allowed_filter_params]
        ),
        action: params[:action]
      )
    )
  end
end

def respond_with_subsection(get)
  respond_to do |format|
    format.json do
      # NOTE: only dump current section, as requested:
      respond_with get.send(current_section[:id])
    end
    format.html do
      render('dashboard_section', locals: { section: current_section, get: get })
    end
  end
end
