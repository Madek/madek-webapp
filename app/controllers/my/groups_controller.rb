class My::GroupsController < MyController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  def show
    @get = Presenters::Groups::GroupShow.new(Group.find(params[:id]), current_user)
    respond_with @get
  end

  def new
  end

  def create
    group = current_user.groups.create!(group_params)

    respond_with group, location: -> { my_groups_url }
  end

  def edit
    @get = Presenters::Groups::GroupEdit.new(Group.find(params[:id]), current_user)
    respond_with @get
  end

  def update
    group = current_user.groups.find(params[:id])
    group.update!(group_params)

    respond_with group, location: -> { my_groups_url }
  end

  def destroy
    group = current_user.groups.find(params[:id])
    group.destroy!

    respond_with group, location: -> { my_groups_url }
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

end
