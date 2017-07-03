class GroupsController < ApplicationController
  include Concerns::ResourceListParams
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  def show
    group = find_group_and_authorize

    resources_type = params.permit(:type).fetch(:type, nil)

    respond_with(
      @get = Presenters::Groups::GroupShow.new(
        group,
        current_user,
        resources_type,
        resource_list_by_type_param)
    )
  end

  private

  def find_group_and_authorize
    group = Group.find(params[:id])
    auth_authorize group
    group
  end
end
