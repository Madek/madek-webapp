class AppAdmin::MetaContextGroupsController < AppAdmin::BaseController
  def index
    @meta_context_groups = MetaContextGroup.all
  end

  def edit
    @meta_context_group = MetaContextGroup.find(params[:id])
  end

  def update
    @meta_context_group = MetaContextGroup.find(params[:id])
    @meta_context_group.update(meta_context_group_params)

    redirect_to app_admin_meta_context_groups_url
  end

  def new
    @meta_context_group = MetaContextGroup.new
  end

  def create
    @meta_context_group = MetaContextGroup.create(meta_context_group_params)

    redirect_to app_admin_meta_context_groups_url
  end

  private

  def meta_context_group_params
    params.require(:meta_context_group).permit!
  end
end
