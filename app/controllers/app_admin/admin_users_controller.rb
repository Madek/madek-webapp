class AppAdmin::AdminUsersController < AppAdmin::BaseController
  include Concerns::SetSession

  def index
    begin
      @admin_users = User.with_resources_amount.admin_users

      @admin_users = @admin_users.page(params[:page])

      search_terms = params.try(:[],:filter).try(:[],:search_terms)

      if !search_terms.blank?
        case params.try(:[], :sort_by) 
        when 'trgm_rank'
          @admin_users= @admin_users.trgm_rank_search(search_terms) \
            .joins(:person).order("people.last_name ASC, people.first_name ASC")
        when 'text_rank'
          @admin_users= @admin_users.text_rank_search(search_terms) \
            .joins(:person).order("people.last_name ASC, people.first_name ASC")
        else
          @admin_users= @admin_users.text_search(search_terms)
        end
      end

      # reorder has to come after text-search; 
      # textacular orders by ranking which might cut off results
      case params.try(:[], :sort_by) || 'last_name_first_name'
      when 'resources_amount'
        @sort_by = :resources_amount
        @admin_users = @admin_users.sort_by_resouces_amount
      when 'last_name_first_name'
        @sort_by = :last_name_first_name
        @admin_users = @admin_users.joins(:person).reorder("people.last_name ASC, people.first_name ASC")
      when 'login'
        @sort_by = :login
        @admin_users = @admin_users.reorder("login ASC")
      when 'trgm_rank'
        @sort_by = :trgm_rank
        raise "Search term must not be blank!" if search_terms.blank? 
      when 'text_rank'
        @sort_by = :text_rank
        raise "Search term must not be blank!" if search_terms.blank? 
      end
    rescue Exception => e
      @admin_users = User.admin_users.where("false = true").page(0)
      @error_message= e.to_s
    end
  end

  def autocomplete_search 
    @admin_users = User.admin_users.reorder(:autocomplete).where("autocomplete ilike ?","#{params[:search_term]}%").limit(50)
    render json: @admin_users.map(&:autocomplete)
  end

  def search 
    @admin_users = User.admin_users.text_search(params[:search_term]).limit(50).order_by_last_name_first_name
    render json: @admin_users.map{|u| {name: u.name, login: u.login}}
  end

  def show
    @admin_user = User.admin_users.find params[:id]
    @groups =  @admin_user.groups
    @groups = @groups.page(params[:page])
  end

  def edit
    @admin_user = User.admin_users.find params[:id]
  end

  def new 
    @admin_user = User.new
    @admin_user.build_admin_user
  end
  alias :form_create_with_user :new

  def update
    @admin_user = User.admin_users.find(params[:id])
    @admin_user.update_attributes! user_params
    redirect_to app_admin_user_path(@admin_user), flash: {success: "The admin user has been updated."}
  rescue => e
    redirect_to edit_app_admin_user_path(@admin_user), flash: {error: e.to_s}
  end

  def create
    @admin_user = User.create! user_params
    AdminUser.create!(user: @admin_user)
    redirect_to app_admin_admin_user_path(@admin_user), flash: {success: "A new admin user has been created"}
  rescue => e
    redirect_to new_app_admin_admin_user_path, flash: {error: e.to_s}
  end

  def create_with_user
    ActiveRecord::Base.transaction do
      @person = Person.create! person_params
      @admin_user = User.create! user_params.merge({person: @person}) 
      AdminUser.create!(user: @admin_user)

      redirect_to app_admin_admin_users_path, flash: {success: "A new admin user with person has been created!"}
    end
  rescue => e
    redirect_to app_admin_admin_users_path, flash: {error: e.to_s}
  end

  def destroy
    User.destroy!(params[:id])
    
    redirect_to app_admin_admin_users_path, flash: {success: "The admin user has been destroyed!"}
  rescue => e
    redirect_to app_admin_admin_users_path, flash: {error: e.to_s}
  end

  def remove_from_admins
    AdminUser.find_by(user_id: params[:id]).destroy!

    redirect_to app_admin_admin_users_path, flash: {success: "The user has been removed from admins."}
  rescue => e
    redirect_to app_admin_admin_users_path, flash: {error: e.to_s}
  end

  def switch_to
    reset_session
    set_madek_session(User.find(params[:id]))
    redirect_to root_url
  end

  def reset_usage_terms
    @admin_user = User.find(params[:id])
    @admin_user.reset_usage_terms
    redirect_to app_admin_admin_users_path
  end

  private

  def user_params
    params.require(:user).permit(:login, :email, :password, :notes, :person_id)
  end

  def person_params
    params.require(:person).permit(:first_name, :last_name)
  end
end
