class MetaContextGroupsController< ApplicationController

  ##
  # returns a list of all MetaContextGroups
  #
  # @resource /meta_context_groups
  #
  # @action GET
  #
  # @example_request {}
  # @example_response  [{"id":1,"name":"TheGroupName"}]
  #
  # @response_field [integer] id  The id of the MetaContextGroup.
  # @response_field [string] name   The name of the MetaContextGroup.
  # 
  #
  def index
    meta_context_groups = MetaContextGroup.all
    render :json => view_context.json_for(meta_context_groups)
  end

end
