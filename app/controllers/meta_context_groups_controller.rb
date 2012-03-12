class MetaContextGroupsController< ApplicationController

  def index
    @meta_context_groups = MetaContextGroup.all
  end

end
