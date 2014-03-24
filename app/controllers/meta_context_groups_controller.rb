class MetaContextGroupsController< ApplicationController

  def index
    meta_context_groups = MetaContextGroup.all
    render :json => view_context.json_for(meta_context_groups)
  end

end
