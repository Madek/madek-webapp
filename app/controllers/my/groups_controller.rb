class My::GroupsController < MyController
  include Concerns::ResourceListParams
  include Concerns::JSONSearch

  def index
    respond_to do |f|
      f.json { get_and_respond_with_json }
      f.html # default
    end
  end

  # Used by get_and_respond_with_json in json_search.rb
  def search_params
    [params[:search_term], nil, params[:scope]]
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

    respond_to do |format|
      format.json do
        flash[:success] = I18n.t(:group_was_deleted)
        render(json: {})
      end
      format.html do
        redirect_to(
          my_groups_path,
          flash: { success: I18n.t(:group_was_deleted) })
      end
    end
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

  def member_params
    params.require(:group)[:users]
  end

  def update_members!(group)
    group.users = []
    member_params.each do |user_id, selected|
      if selected == 'true'
        group.users << User.find(user_id) if user_id.present?
      end
    end
  end

end
