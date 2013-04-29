class AppAdmin::GroupsController < AppAdmin::BaseController
  def index
    @groups = Group.reorder("name ASC, ldap_name ASC").page(params[:page])

    if !params[:fuzzy_search].blank?
      @groups = @groups.fuzzy_search(params[:fuzzy_search])
    end
  end

  def show
    @group = Group.find params[:id]
    @users = @group.users

    if !params[:fuzzy_search].blank?
      @users= @users.fuzzy_search(params[:fuzzy_search])
    end

    @users= @users.page(params[:page])
  end

  def edit
    @group = Group.find params[:id]
  end

  def form_add_user
    @group = Group.find params[:id]
  end

  def add_user
    begin
      @group= Group.find params[:id]
      @user = User.find(params[:user_id])
      @group.users << @user
      redirect_to app_admin_group_path(@group), flash: {success: "The user has been added"}
    rescue => e
      redirect_to app_admin_group_path(@group), flash: {error: e.to_s}
    end
  end

end
