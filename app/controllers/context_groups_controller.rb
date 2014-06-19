class ContextGroupsController< ApplicationController

  def index
    context_groups = ContextGroup.all
    render :json => view_context.json_for(context_groups)
  end

end
