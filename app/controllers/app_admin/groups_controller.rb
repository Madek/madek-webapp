class AppAdmin::GroupsController < AppAdmin::BaseController
  def index

    begin 

      @groups = Group.page(params[:page])

      @type = :all
      if !params[:type].blank? && params[:type] != "all"
        @groups = @groups.where(type: type_parameter)
        @type = params[:type]
      end

      @search_terms = params.try(:[],:filter).try(:[],:search_terms)

      if ! @search_terms.blank?
        @search_terms = @search_terms.strip
        case params.try(:[], :sort_by) 
        when 'text_rank'
          @groups= @groups.text_rank_search(@search_terms) \
            .order("name ASC, ldap_name ASC")
        when 'trgm_rank'
          @groups= @groups.trgm_rank_search(@search_terms) \
            .order("name ASC, ldap_name ASC")
        else
          @groups= @groups.text_search(@search_terms)
        end
      end

      case params.try(:[], :sort_by) || 'name'
      when 'name'
        @sort_by= :name
        @groups= @groups.reorder("name ASC, ldap_name ASC")
      when 'amount'
        @sort_by = :amount
        @groups = @groups.reorder("users_count DESC, name ASC, ldap_name ASC")
      when 'trgm_rank'
        @sort_by = :trgm_rank
        raise "Search term must not be blank!" if @search_terms.blank? 
      when 'text_rank'
        @sort_by = :text_rank
        raise "Search term must not be blank!" if @search_terms.blank? 
      end

    rescue Exception => e
      @groups = Group.where("true = false").page(params[:page])
      @error_message= e.to_s
    end

  end

  def new
    @group = Group.new params[:group]
  end

  def update
    begin
      if params.has_key?(:institutional_group)
        params[:group] = params.delete(:institutional_group)
      end
      @group = Group.find(params[:id])
      @group.update_attributes!(group_params)
      redirect_to app_admin_group_path(@group), flash: {success: "The group has been updated."}
    rescue => e
      redirect_to edit_app_admin_group_path(@group), flash: {error: e.to_s}
    end
  end

  def create
    begin
      @group = Group.create!(group_params)
      redirect_to app_admin_group_path(@group), flash: {success: "A new group has been created."}
    rescue => e
      redirect_to new_app_admin_group_path(@group),flash: {error: e.to_s}
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

  def destroy
    begin
      @group = Group.find params[:id]
      @group.destroy
      redirect_to app_admin_groups_path, flash: {success: "The Group has been deleted."}
    rescue => e
      redirect_to :back, flash: {error: e.to_s}
    end
  end

  def form_add_user
    @group = Group.find params[:id]
  end

  def add_user
    begin
      @group = Group.find params[:id]
      @user  = find_user
      if @group.users.include?(@user)
        flash = {error: "The user <b>#{@user.login}</b> already belongs to this group.".html_safe}
      else
        @group.users << @user
        flash = {success: "The user <b>#{@user.login}</b> has been added.".html_safe}
      end
      redirect_to app_admin_group_path(@group), flash: flash
    rescue => e
      redirect_to app_admin_group_path(@group), flash: {error: e.to_s}
    end
  end

  def show_media_sets
    @group = Group.find(params[:id])
    @permission_presets = PermissionPreset.where.not(name: "Gesperrt")
  end

  def show_media_entries
    @group = Group.find(params[:id])
    @permission_presets = PermissionPreset.where.not(name: "Gesperrt")
  end

  private

  def type_parameter
    params[:type].split("_").map(&:capitalize).join("")
  end

  def find_user
    if params[:query] =~ /^\[\w+\]$/ && params[:user_id].blank?
      User.find_by_login(params[:query][1..-2])
    else
      User.find(params[:user_id])
    end
  end

  def group_params
    params.require(:group).permit(:name)
  end

end
