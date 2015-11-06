class My::GroupsController < MyController
  include Concerns::ResourceListParams
  include Concerns::JSONSearch

  def index
    respond_to do |f|
      f.json { get_and_respond_with_json }
      f.html # default
    end
  end

  def show
    represent(find_group_and_authorize, Presenters::Groups::GroupShow)
  end

  def new
  end

  def create
    group = current_user.groups.create!(group_params)

    respond_with group, location: -> { my_groups_url }
  end

  def edit
    represent(find_group_and_authorize, Presenters::Groups::GroupEdit)
  end

  def update
    group = current_user.groups.find(params[:id])
    authorize group, :update_and_manage_members?
    ActiveRecord::Base.transaction do
      group.update!(group_params)
      update_members!(group)
    end

    respond_with group, location: -> { my_groups_url }
  end

  def destroy
    group = current_user.groups.find(params[:id])
    authorize group
    group.destroy!

    respond_with group, location: -> { my_groups_url }
  end

  private

  def represent(resource, presenter)
    respond_with(
      @get = presenter.new(
        resource, current_user, list_conf: resource_list_params))
  end

  def find_group_and_authorize
    group = Group.find(params[:id])
    authorize group
    group
  end

  def group_params
    params.require(:group).permit(:name)
  end

  def member_params
    params.require(:group).permit(user: [login: []])
  end

  def update_members!(group)
    group.users = []
    member_params[:user][:login].each do |login|
      group.users << User.find_by!(login: login) if login.present?
    end
  end

end
