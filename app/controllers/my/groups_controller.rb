class My::GroupsController < MyController
  include Concerns::JSONSearch

  def index
    respond_to do |f|
      f.json { get_and_respond_with_json }
      f.html # default
    end
  end

  def show
    @get =
      Presenters::Groups::GroupShow.new(find_group_and_authorize, current_user)
    respond_with @get
  end

  def new
  end

  def create
    group = current_user.groups.create!(group_params)

    respond_with group, location: -> { my_groups_url }
  end

  def edit
    @get =
      Presenters::Groups::GroupEdit.new(find_group_and_authorize, current_user)
    respond_with @get
  end

  def update
    group = current_user.groups.find(params[:id])
    authorize group
    group.update!(group_params)

    respond_with group, location: -> { my_groups_url }
  end

  def destroy
    group = current_user.groups.find(params[:id])
    authorize group
    group.destroy!

    respond_with group, location: -> { my_groups_url }
  end

  def add_member
    group = current_user.groups.find(params[:id])
    authorize group, :add_member?
    user = User.find_by(login: params[:member][:login])

    group.users << user if user

    respond_with group, location: -> { edit_my_group_path(group) }
  end

  def remove_member
    group = current_user.groups.find(params[:id])
    user = User.find(params[:member_id])
    authorize group, :remove_member?

    group.users.destroy(user)

    respond_with group, location: -> { edit_my_group_path(group) }
  end

  private

  def find_group_and_authorize
    group = Group.find(params[:id])
    authorize group
    group
  end

  def group_params
    params.require(:group).permit(:name)
  end

end
