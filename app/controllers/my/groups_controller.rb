class My::GroupsController < ApplicationController
  include Concerns::ResourceListParams
  include Concerns::My::DashboardSections
  include Concerns::UserScopes::Dashboard

  def index
    auth_authorize :dashboard, :logged_in?

    sections = sections_definition.map do |id, s|
      [id, s.merge(id: id)]
    end.to_h

    get = Presenters::Users::UserDashboard.new(
      current_user,
      user_scopes_for_dashboard(current_user),
      Presenters::Users::DashboardHeader.new,
      with_count: (params[:action] != 'dashboard'),
      list_conf: { order: 'created_at DESC' }.merge(
        resource_list_params.merge(per_page: 6, page: 1)
      ),
      # activity_stream_conf: activity_stream_params,
      action: params[:action],
      is_async_attribute: true
    )

    @get = Presenters::Users::DashboardSection.new(
      get.groups_and_delegations,
      sections,
      nil
    )

    respond_with @get, layout: 'app_with_sidebar', template: 'my/groups/index'
  end

  def show
    group = get_authorized_resource

    resources_type = params.permit(:type).fetch(:type, nil)

    respond_with(
      @get = Presenters::Groups::GroupShow.new(
        group,
        current_user,
        resources_type,
        resource_list_by_type_param,
        { context_key_id: params[:context_key_id], search_term: params[:search_term] })
    )
  rescue ActiveRecord::RecordNotFound
    try_redirect_to_subsequent_resource { |resource| my_group_path(resource) }
  end

  def new
    auth_authorize :dashboard, :logged_in?

    sections = sections_definition.map do |id, s|
      [id, s.merge(id: id)]
    end.to_h

    @get = Presenters::Users::DashboardSection.new(
      nil,
      sections,
      nil
    )

    respond_with @get, layout: 'app_with_sidebar'
  end

  def create
    auth_authorize :dashboard, :logged_in?

    group = current_user.groups.create!(group_params)

    respond_with group, location: -> { my_groups_url }
  end

  def edit
    sections = sections_definition.map do |id, s|
      [id, s.merge(id: id)]
    end.to_h

    @get = Presenters::Users::DashboardSection.new(
      presenterify(get_authorized_resource, Presenters::Groups::GroupEdit),
      sections,
      nil
    )

    respond_with @get, layout: 'app_with_sidebar'
  end

  def update
    group = current_user.groups.find(params[:id])
    auth_authorize group, :update_and_manage_members?
    ActiveRecord::Base.transaction do
      group.update!(group_params)
      update_members!(group)
    end

    respond_with group, location: -> { my_groups_url }
  end

  def destroy
    group = current_user.groups.find(params[:id])
    auth_authorize group
    group.destroy!

    respond_to do |format|
      format.json do
        flash[:success] = I18n.t(:group_was_deleted)
        render(json: {})
      end
      format.html do
        redirect_to(
          my_groups_path,
          flash: { success: I18n.t(:group_was_deleted) })
      end
    end
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def member_params
    params.require(:group)[:users]
  end

  def update_members!(group)
    group.users = []
    member_params.each do |user_id, selected|
      if selected == 'true'
        group.users << User.find(user_id) if user_id.present?
      end
    end
  end

end
