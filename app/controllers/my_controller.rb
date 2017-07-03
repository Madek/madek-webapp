class MyController < ApplicationController
  include Concerns::ResourceListParams
  include Concerns::UserScopes::Dashboard
  include Concerns::NewCollectionModal
  include Concerns::ActivityStream
  include Concerns::Clipboard
  include Concerns::My::DashboardSections

  def dashboard
    auth_authorize :dashboard, :logged_in?

    user_dashboard = create_user_dashboard(
      list_conf: { order: 'created_at DESC' }.merge(
        resource_list_params.merge(per_page: 6, page: 1)
      ),
      is_async_attribute: params['___sparse']
    )

    @get = Presenters::Users::Dashboard.new(
      user_dashboard,
      create_sections
    )

    respond_with @get, layout: 'application'
  end

  def dashboard_section
    auth_authorize :dashboard, :logged_in?

    current_section = determine_current_section

    user_dashboard = create_user_dashboard(
      list_conf: { order: 'created_at DESC' }.merge(
        { per_page: 12 }.merge(
          resource_list_params(
            params,
            current_section.try(:[], :allowed_filter_params)
          )
        )
      ),
      is_async_attribute: true,
      json_path: 'section_resources.resources'
    )

    @get = Presenters::Users::DashboardSection.new(
      user_dashboard.send(current_section[:id]),
      create_sections,
      current_section
    )

    respond_with @get, layout: 'app_with_sidebar'
  end

  private

  def determine_current_section
    section_name = params.permit(:section).try(:[], :section).try(:to_sym)

    unless section_name
      raise ActionController::RoutingError.new(404), 'No such dashboard section!'
    end

    section = create_sections.try(:[], section_name)

    unless section
      raise ActionController::RoutingError.new(404), 'No such dashboard section!'
    end

    section
  end

  def create_sections
    sections_definition.map do |id, s|
      [id, s.merge(id: id)]
    end.to_h
  end

  def create_user_dashboard(
    list_conf: nil,
    is_async_attribute: nil,
    json_path: nil)

    Presenters::Users::UserDashboard.new(
      current_user,
      user_scopes_for_dashboard(current_user),
      Presenters::Users::DashboardHeader.new,
      with_count: (params[:action] != 'dashboard'),
      list_conf: list_conf,
      activity_stream_conf: activity_stream_params,
      action: params[:action],
      is_async_attribute: is_async_attribute,
      json_path: json_path
    )
  end
end
