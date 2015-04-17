class Admin::GroupsController < AdminController
  def index
    @groups = sort_and_filter(params)

    remember_vocabulary_url_params
  rescue ArgumentError => e
    @groups = Group.all.page(params[:page])
    flash[:error] = e.to_s
  end

  def new
    @group = Group.new params[:group]
  end

  define_update_action_for(Group)

  def create
    @group = Group.create!(group_params)

    respond_with @group, location: -> { admin_group_path(@group) }
  end

  def show
    @group = Group.find params[:id]
    @users = @group.users

    unless params[:fuzzy_search].blank?
      @users = @users.fuzzy_search(params[:fuzzy_search])
    end

    @users = @users.page(params[:page])
  end

  def edit
    @group = Group.find params[:id]
  end

  def destroy
    @group = Group.find(params[:id])

    if @group.users.empty?
      @group.destroy!
      respond_with @group, location: -> { admin_groups_path }
    else
      redirect_to params[:redirect_path], flash: {
        error: 'The group contains users and cannot be destroyed.'
      }
    end
  end

  def form_add_user
    @group = Group.find params[:id]
  end

  def add_user
    @group = Group.find params[:id]
    @user  = User.find params[:user_id]
    if @group.users.include?(@user)
      flash = { error: "The user <b>#{@user.login}</b> "\
                       'already belongs to this group.'.html_safe }
    else
      @group.users << @user
      flash = { success: "The user <b>#{@user.login}</b> "\
                         'has been added.'.html_safe }
    end

    redirect_to admin_group_path(@group), flash: flash
  end

  def form_merge_to
    @group = Group.departments.find(params[:id])
  end

  def merge_to
    originator = Group.departments.find(params[:id])
    receiver = Group.departments.find(params[:id_receiver].strip)

    originator.merge_to(receiver)

    redirect_to admin_group_url(receiver), flash: { success: 'The group '\
                                                             'has been merged.' }
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
  alias_method :update_group_params, :group_params

  def sort_and_filter(params)
    groups = Group.page(params[:page]).per(25)
    groups = groups.by_type(params[:type]) \
      if params[:type].present?
    search_terms = params[:search_terms].strip \
      if params[:search_terms].present?
    groups = groups.filter_by(search_terms, params[:sort_by]) \
      if params[:sort_by].present?
    groups
  end
end
