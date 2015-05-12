class Admin::UsersController < AdminController
  include Concerns::MadekSession

  before_action :find_user, except: [
    :index, :new, :new_with_person, :create, :remove_user_from_group
  ]
  before_action :initialize_user, only: [:new, :new_with_person]

  def index
    @users = User.page(params[:page]).per(16)

    if params[:search_term].present?
      @users = @users.filter_by(params[:search_term])
    end
    @users = @users.admin_users if params[:admins_only] == '1'
    @users = @users.sort_by(params[:sort_by]) if params[:sort_by].present?
  end

  def reset_usage_terms
    @user.reset_usage_terms

    redirect_to admin_users_url, flash: {
      success: ['The usage terms have been reset.']
    }
  end

  def show
  end

  def edit
  end

  def new
  end

  def new_with_person
    @user.build_person
  end

  def update
    @user.update!(user_params)

    redirect_to admin_user_path(@user), flash: {
      success: ['The user has been updated.']
    }
  end

  def create
    @user = User.new(user_params)
    @user.save!

    redirect_to admin_users_path, flash: {
      success: [success_message_after_create]
    }
  end

  def destroy
    @user.destroy

    redirect_to admin_users_path, flash: {
      success: ['The user has been deleted.']
    }
  end

  def switch_to
    reset_session
    destroy_madek_session
    set_madek_session(@user)
    redirect_to root_url
  end

  def grant_admin_role
    Admin.create!(user: @user)

    redirect_to params[:redirect_path], flash: {
      success: ['The admin role has been granted to the user.']
    }
  end

  def remove_admin_role
    Admin.find_by(user_id: @user.id).destroy!

    redirect_to params[:redirect_path], flash: {
      success: ['The admin role has been removed from the user.']
    }
  end

  def remove_user_from_group
    @group = Group.find params[:group_id]
    @group.users.delete User.find(params[:user_id])
    redirect_to admin_group_path(@group), flash: {
      success: ['The user has been removed.']
    }
  end

  private

  def initialize_user
    @user = User.new
  end

  def find_user
    @user = User.find(params[:id])
  end

  def person_attributes?
    params[:user][:person_attributes] rescue false
  end

  def success_message_after_create
    if person_attributes?
      'The user with person has been created.'
    else
      'The user for existing person has been created.'
    end
  end

  def user_params
    params.require(:user).permit!
  end
end
