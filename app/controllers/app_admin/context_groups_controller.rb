class AppAdmin::ContextGroupsController < AppAdmin::BaseController
  def index
    @context_groups = ContextGroup.all
  end

  def edit
    @context_group = ContextGroup.find(params[:id])
  end

  def update
    @context_group = ContextGroup.find(params[:id])
    @context_group.update(context_group_params)

    redirect_to app_admin_context_groups_url, flash: {success: "The meta context group has been updated."}
  rescue => e
    redirect_to app_admin_context_groups_url, flash: {error: e.message}
  end

  def new
    @context_group = ContextGroup.new
  end

  def create
    @context_group = ContextGroup.create(context_group_params)

    redirect_to app_admin_context_groups_url, flash: {success: "A meta context group has been created."}
  rescue => e
    redirect_to app_admin_context_groups_url, flash: {error: e.message}
  end

  private

  def context_group_params
    params.require(:context_group).permit(:name, contexts_attributes: [:id, :position, :context_group_id])
  end
end
