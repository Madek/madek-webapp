class My::WorkflowsController < ApplicationController
  include Concerns::My::DashboardSections

  before_action { auth_authorize(:dashboard, :logged_in?) }

  def index
    auth_authorize :workflow
    @get =
      Presenters::Users::DashboardSection.new(
        Presenters::Workflows::WorkflowIndex.new(current_user),
        sections_definition,
        nil
      )
    respond_with(@get, layout: 'app_with_sidebar')
  end

  def new
    auth_authorize :workflow
    @get =
      Presenters::Users::DashboardSection.new(
        Presenters::Workflows::WorkflowNew.new(Workflow.new, current_user),
        sections_definition,
        nil
      )
    respond_with(@get, layout: 'app_with_sidebar')
  end

  def create
    auth_authorize :workflow
    WorkflowCreator.new(workflow_params, current_user).call

    redirect_to my_workflows_path, notice: 'Workflow has been created successfully.'
  end

  def edit
    workflow = Workflow.find(params[:id])
    auth_authorize workflow
    @get =
      Presenters::Users::DashboardSection.new(
        workflow_edit_data(workflow),
        sections_definition,
        nil
      )
    respond_with(@get, layout: 'app_with_sidebar')
  end

  def update
    workflow = Workflow.find(params[:id])
    auth_authorize workflow
    workflow.update!(workflow_params)
    respond_with(workflow_edit_data(workflow))
  end

  def update_owners
    workflow = Workflow.find(params[:id])
    auth_authorize workflow
    users_or_people_ids = params.require(:workflow).fetch(:owners, [])
    workflow.owners = User.where(id: users_or_people_ids)
    respond_with(workflow_edit_data(workflow))
  end

  def preview
    workflow = Workflow.find(params[:id])
    auth_authorize workflow
    @get =
      Presenters::Users::DashboardSection.new(
        Presenters::Workflows::WorkflowPreview.new(
          workflow,
          current_user,
          fill_data_mode: fill_data_mode?
        ),
        sections_definition,
        nil
      )
    respond_with(@get, layout: 'app_with_sidebar')
  end

  def save_and_not_finish
    @workflow = Workflow.find(params[:id])
    auth_authorize @workflow
    result = WorkflowLocker::Service.new(@workflow, meta_data_params).save_only
    if result == true
      flash[:notice] = 'Meta data has been updated successfully.'
      redirect_to edit_my_workflow_path(@workflow)
    else
      handle_errors(result)
    end
  end

  def finish
    @workflow = Workflow.find(params[:id])
    auth_authorize @workflow
    result = WorkflowLocker::Service.new(@workflow, meta_data_params).call
    if result == true
      redirect_to edit_my_workflow_path(@workflow), notice: 'Workflow has been finished!'
    else
      handle_errors(result)
    end
  end

  private

  def workflow_edit_data(workflow)
    Presenters::Workflows::WorkflowEdit.new(workflow, current_user)
  end

  def meta_data_value_params
    %i(string uuid isNew label type subtype term first_name last_name pseudonym role)
  end

  def workflow_params
    params.require(:workflow).permit(
      :name,
      { owner_ids: [] },
      common_permissions: [
        :responsible,
        { write: %i(uuid type) },
        { read: %i(uuid type) },
        :read_public
      ],
      common_meta_data: [
        :meta_key_id,
        { value: meta_data_value_params },
        :is_common,
        :is_mandatory,
        :is_overridable
      ]
    )
  end

  def meta_data_params
    params.fetch(:meta_data, {})
  end

  def handle_errors(errors)
    error_message = ['Workflow cannot be finished because of following errors:']
    errors.each do |resource_title, messages|
      error_message << "#{resource_title}: #{messages.join(', ')}"
    end
    flash[:error] = error_message.join("\n")
    redirect_to preview_my_workflow_path(@workflow)
  end

  def fill_data_mode?
    params.fetch(:fill_data, false) == 'true'
  end
end
