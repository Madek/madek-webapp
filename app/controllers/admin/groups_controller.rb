class Admin::GroupsController < AdminController
  def index
    @groups = sort_and_filter(params)
  rescue => e
    @groups = Group.all.page(params[:page])
    flash[:error] = e.to_s
  end

  def new
    @group = Group.new params[:group]
  end

  def update
    @group = Group.find(params[:id])
    @group.update_attributes!(group_params)
    redirect_to admin_group_path(@group), flash: { success: 'The group '\
                                                            'has been updated.' }
  rescue => e
    redirect_to edit_admin_group_path(@group), flash: { error: e.to_s }
  end

  def create
    @group = Group.create!(group_params)
    redirect_to admin_group_path(@group), flash: { success: 'A new group '\
                                                           'has been created.' }
  rescue => e
    redirect_to new_admin_group_path(@group), flash: { error: e.to_s }
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
      redirect_path = admin_groups_path
      flash_message =
        { success: 'The group has been deleted.' }
    else
      redirect_path = :back
      flash_message = { error: 'The group contains users '\
                               'and cannot be deleted.' }
    end
    redirect_to redirect_path, flash: flash_message
  rescue => e
    redirect_to :back, flash: { error: e.to_s }
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
  rescue => e
    redirect_to admin_group_path(@group), flash: { error: e.to_s }
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
  rescue => e
    redirect_to admin_group_url(originator), flash: { error: e.to_s }
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def sort_and_filter(params)
    groups = Group.page(params[:page])
    groups = groups.by_type(params[:type]) \
      if params[:type].present?
    search_terms = params[:search_terms].strip \
      if params[:search_terms].present?
    groups = groups.filter_by(search_terms, params[:sort_by]) \
      if params[:sort_by].present?
    groups
  end
end
