class MetaContextGroupsController< ApplicationController

  ##
  #
  # @resouce /meta_context_groups
  #
  # @action GET
  #
  # @example_request {}
  # @example_response  [{"id":1,"name":"TheGroupName"}]
  #
  ##
  def index
    @meta_context_groups = MetaContextGroup.all
  end

end
