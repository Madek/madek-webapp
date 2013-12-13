class AppAdmin::UsersController < AppAdmin::BaseController

  def index
    respond_to do |format|
      format.json {
        users = Person.search(params[:query]).map(&:user).compact
        render :json => view_context.json_for(users)
      }
      format.html {
        @users = User.with_resources_amount

        if params.try(:[], :sort_by) == 'resources_amount'
          @sort_by = :resources_amount
        else
          @sort_by = :login
          @users = @users.reorder("login ASC")
        end

        @users = @users.page(params[:page])
  
        if ! (fuzzy_search = params.try(:[],:filter).try(:[],:fuzzy_search)).blank?
          @users = @users.fuzzy_search(fuzzy_search)
        end
      }
    end
  end

  def show
    @user = User.find params[:id]
    @groups =  @user.groups
    @groups = @groups.page(params[:page])
  end

  def edit
    @user = User.find params[:id]
  end

  def new 
    @user = User.new
  end

  def update
    begin
      @user = User.find(params[:id])
      @user.update_attributes! user_params
      redirect_to app_admin_user_path(@user), flash: {success: "The user has been updated."}
    rescue => e
      redirect_to edit_app_admin_user_path(@user), flash: {error: e.to_s}
    end
  end


  def create
    begin
      @user = User.create! user_params
      redirect_to app_admin_user_path(@user), flash: {success: "A new user has been created"}
    rescue => e
      redirect_to new_app_admin_user_path, flash: {error: e.to_s}
    end
  end


  def create_with_user
    begin
      ActiveRecord::Base.transaction do
        @person = Person.create! person_params
        @user = User.create! user_params.merge({person: @person}) 
        redirect_to app_admin_users_path, flash: {success: "A new user with person has been created!"}
      end
    rescue => e
      redirect_to app_admin_users_path, flash: {error: e.to_s}
    end
  end

  def destroy 
    begin 
      User.destroy(params[:id])
      redirect_to app_admin_users_path, flash: {success: "The user has been destroyed!"}
    rescue => e
      redirect_to app_admin_users_path, flash: {error: e.to_s}
    end
  end


  def remove_user_from_group
    begin
      @group = Group.find params[:group_id]
      @group.users.delete User.find(params[:id])
      redirect_to app_admin_group_path(@group), flash: {success: "The user has been removed"}
    rescue => e
      redirect_to app_admin_group_path(@group), flash: {error: e.to_s}
    end
  end

  def switch_to
    reset_session
    self.current_user = User.find(params[:id])
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def person_params
    params.require(:person).permit!
  end

end
