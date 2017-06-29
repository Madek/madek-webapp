class MyController < ApplicationController
  include Concerns::ResourceListParams
  include Concerns::UserScopes::Dashboard
  include Concerns::NewCollectionModal
  include Concerns::ActivityStream
  include Concerns::UserApiTokens

  include Concerns::Clipboard
  include Concerns::My::DashboardSections

  layout 'app_with_sidebar'

  after_action :verify_policy_scoped

  before_action do
    auth_authorize :dashboard, :logged_in?
    # needed for the sidebar nav, also in controllers that inherit from us:
    init_for_view
  end

  private

  def init_for_view
    @sections = sections_definition.map do |id, s|
      [id, s.merge(id: id)]
    end.to_h
    @get = Presenters::Users::UserDashboard.new(
      current_user,
      user_scopes_for_dashboard(current_user),
      Presenters::Users::DashboardHeader.new,
      with_count: (params[:action] != 'dashboard'),
      list_conf: { order: 'created_at DESC' }.merge(list_conf_by_dashboard_action),
      activity_stream_conf: activity_stream_params,
      action: params[:action])
  end

  def current_section
    section_name = params.permit(:section).try(:[], :section).try(:to_sym)
    return unless section_name
    @current_section ||= @sections.try(:[], section_name)
  end

  def list_conf_by_dashboard_action
    if (params[:action] == 'dashboard')
      resource_list_params.merge(per_page: 6, page: 1)
    else
      { per_page: 12 }.merge \
        resource_list_params(params, current_section.try(:[],
                                                         :allowed_filter_params))
    end
  end
end
