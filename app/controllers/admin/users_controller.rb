# -*- encoding : utf-8 -*-
class Admin::UsersController < Admin::AdminController

  before_filter do
    unless (params[:user_id] ||= params[:id]).blank?
      @user = User.find(params[:user_id])
    end
    @group = Group.find(params[:group_id]) unless params[:group_id].blank?
  end

#####################################################

  def index
    @users = User.all
  end

  def show
  end
  
#####################################################
# nested to person

  before_filter :only => [:new, :create] do
    @person = Person.find(params[:person_id])
  end

  def new
    @user = @person.build_user
  end
  
  def create
    respond_to do |format|
      format.js {
        if params[:user].delete(:password_confirmation) == params[:user][:password] and
          params[:user][:password] = Digest::SHA1.hexdigest(params[:user][:password]) and
          @person.create_user(params[:user])
            render partial: "/admin/people/show", locals: {person: @person}
        else
          render text: "error", status: 500
        end
      }
    end
  end

#####################################################

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
    end if groups
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

end
