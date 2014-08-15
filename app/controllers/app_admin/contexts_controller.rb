class AppAdmin::ContextsController < AppAdmin::BaseController
  def index
    @contexts = Context.all
  end

  def edit
    @context = Context.find(params[:id])
  end

  def update
    @context = Context.find(params[:id])
    @context.update(context_params)

    redirect_to app_admin_contexts_url, flash: {success: "The meta context has been updated"}
  end

  def new
    @context = Context.new
  end

  def create
    @context = Context.create(context_params)

    redirect_to app_admin_contexts_url
  end

  def destroy
    @context = Context.find(params[:id])
    @context.destroy

    redirect_to app_admin_contexts_url, flash: {success: "The meta context has been deleted"}
  end

  def media_sets
    @context = Context.find(params[:id])
    @media_sets = @context.media_sets
  end

  private

  def context_params
    params.require(:context).permit!
  end
end
