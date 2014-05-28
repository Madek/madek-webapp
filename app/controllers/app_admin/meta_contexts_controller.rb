class AppAdmin::MetaContextsController < AppAdmin::BaseController
  def index
    @meta_contexts = MetaContext.all
  end

  def edit
    @meta_context = MetaContext.find(params[:id])
  end

  def update
    @meta_context = MetaContext.find(params[:id])
    @meta_context.update(meta_context_params)

    redirect_to app_admin_meta_contexts_url, flash: {success: "The meta context has been updated"}
  end

  def new
    @meta_context = MetaContext.new
  end

  def create
    @meta_context = MetaContext.create(meta_context_params)

    redirect_to app_admin_meta_contexts_url
  end

  def destroy
    @meta_context = MetaContext.find(params[:id])
    @meta_context.destroy

    redirect_to app_admin_meta_contexts_url, flash: {success: "The meta context has been deleted"}
  end

  private

  def meta_context_params
    params.require(:meta_context).permit!
  end
end
