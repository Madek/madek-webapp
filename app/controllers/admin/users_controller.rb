# -*- encoding : utf-8 -*-
class Admin::UsersController < Admin::AdminController

  before_filter :pre_load

  def index
    @users = User.all
  end

  def show
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    groups = params[:user].delete(:groups_attributes)
    groups.each_pair do |key, group|
      id = group[:id].to_i
      if group[:_destroy]
        @user.groups.delete(Group.find(id))
      elsif !@user.groups.collect(&:id).include?(id)
        @user.groups << Group.find(id)
      end
    end
    @user.update_attributes(params[:user])
    redirect_to admin_users_path
  end
  
#####################################################

  def switch_to
    reset_session # TODO logout_killing_session!
    self.current_user = @user
    redirect_to root_path
  end

  def membership
    if request.post?
      @group.users << @user
      respond_to do |format|
        format.js { render :partial => "admin/groups/user", :object => @user }
      end
    elsif request.delete?
      @group.users.delete(@user)
      respond_to do |format|
        format.js { render :nothing => true } # TODO check if successfully deleted
      end
    end
  end

#####################################################

  private

  def pre_load
      params[:user_id] ||= params[:id]
      @user = User.find(params[:user_id]) unless params[:user_id].blank?
      @group = Group.find(params[:group_id]) unless params[:group_id].blank?
  end

end
