
class AppAdmin::MediaSetsController < AppAdmin::BaseController

  before_filter only: [:show] do
    if (id = params[:id]) and (not id.blank?) and (id =~ /^\d+$/)
      if mr = MediaResource.find_by(previous_id: id)
        redirect_to app_admin_media_set_path(mr.id), status: 301
      end
    end
  end


  def index
    if params[:term].present?
      render json: autocomplete_for(params[:term])
    else
      @media_sets = MediaSet.reorder(created_at: :desc, id: :asc).page(params[:page]).per(16)

      if !params[:fuzzy_search].blank? && fuzzy_query=params[:fuzzy_search]
        @media_sets= @media_sets.joins(user: :person, meta_data: :meta_key) \
          .where("meta_keys.id = 'title'") \
          .fuzzy_search(
            {users: {login: fuzzy_query, email: fuzzy_query}, 
              people: {last_name: fuzzy_query, first_name: fuzzy_query},
              meta_data: {string: fuzzy_query}},false)
      end
    end
  end

  def show
    @media_set = MediaSet.find params[:id]
  end

  def edit
    @media_set = MediaSet.find params[:id]
  end

  def update
    begin
      @media_set = MediaSet.find params[:id]
      @media_set.update_attributes(media_set_params)
      redirect_to app_admin_media_sets_path, flash: {success: "The media set has been saved successfuly."}
    rescue => e
      redirect_to app_admin_media_sets_path, flash: {error: e.to_s}
    end
  end

  def destroy
    begin
      @media_set = MediaSet.find params[:id]
      @media_set.destroy
      redirect_to app_admin_media_sets_url, flash: {success: "The media set has been deleted without related resources"}
    rescue => e
      redirect_to app_admin_media_sets_url, flash: {error: e.to_s}
    end
  end

  def delete_with_child_media_resources
    begin
      ActiveRecord::Base.transaction do
        @media_set = MediaSet.find params[:id]
        @media_set.child_media_resources.each{|mr| raise unless mr.destroy}
        @media_set.destroy
        redirect_to app_admin_media_sets_path, 
          flash: {success: "The Mediaset with the id #{params[:id]} and all including resources have been removed!"}
      end
    rescue Exception => e
      if @media_set
        redirect_to app_admin_media_set_path(@media_set), flash: {error: e.to_s}
      else
        redirect_to app_admin_media_sets_path, flash: {error: e.to_s}
      end
    end
  end

  def change_ownership_form
    @media_set = MediaSet.find(params[:id])
  end

  def change_ownership
    unless transfer_option_available?
      redirect_to :back, flash: { notice: 'Choose at least one of transfer option.' } and return
    end

    ActiveRecord::Base.transaction do
      @media_set = MediaSet.find(params[:id])
      user = User.find(params[:user_id])
      @success_messages = []

      transfer_ownership_of_media_set(@media_set, user)

      @media_set.child_media_resources.each do |mr|
        transfer_children_media_entries(mr, user)
        transfer_children_sets(mr, user)
      end

      @success_messages = @success_messages.uniq.join('<br>')

      redirect_to app_admin_media_set_path,
        flash: {success: @success_messages.html_safe}
    end
  rescue Exception => e
    if @media_set
      redirect_to app_admin_media_set_path(@media_set), flash: {error: e.to_s}
    else
      redirect_to app_admin_media_sets_path, flash: {error: e.to_s}
    end
  end

  def manage_individual_contexts 
    @media_set= MediaSet.find params[:media_set_id]
    @individual_contexts = @media_set.individual_contexts.reorder(:position,:id)
    @other_contexts = 
      if @individual_contexts.count > 0
        Context.where("id NOT IN (?)",@media_set.individual_context_ids).reorder(:position,:id)
      else
        Context.reorder(:position,:id)
      end
  end

  def remove_individual_context
    @media_set = MediaSet.find params[:media_set_id]
    @context = Context.find params[:id]
    @media_set.individual_contexts.delete @context
    redirect_to manage_app_admin_media_set_individual_contexts_path(@media_set), 
      flash: {success: "The context has been revmoved from the media-set."}
  end

  def add_individual_context
    @media_set = MediaSet.find params[:media_set_id]
    @context = Context.find params[:id]
    @media_set.add_individual_context(@context)
    redirect_to manage_app_admin_media_set_individual_contexts_path(@media_set), 
      flash: {success: "The context has been added to the media-set."}
  end

  private
  def media_set_params
    params.require(:media_set).permit(:id, :user_id)
  end

  def autocomplete_for(term)
    MediaSet.joins(:meta_data) \
      .where("meta_data.string ILIKE :string AND meta_data.meta_key_id='title'", string: "%#{term}%") \
      .map do |media_set|
       {id: media_set.id, label: media_set.title, value: media_set.title}
      end.sort_by { |hash| hash[:label] }
  end

  def delete_permissions_for(user, resource)
    userpermissions = user.userpermissions.find_by(media_resource_id: resource.id)
    userpermissions.delete if userpermissions.present?
  end

  def grant_all_permissions_for(user, resource)
    permission_keys = Userpermission::ALLOWED_PERMISSIONS
    permissions_hash = Hash[permission_keys.map { |key| [key, true] }]

    Userpermission.find_or_create_by(
      media_resource_id: resource.id,
      user_id: user.id
    ).update_attributes!(permissions_hash)
  end

  def transfer_option_available?
    params[:transfer_ownership].present? ||
      params[:transfer_children_sets].present? ||
      params[:transfer_children_media_entries].present?
  end

  def transfer_children_media_entries(resource, new_owner)
    if params[:transfer_children_media_entries].present? && resource.type == 'MediaEntry'
      if params[:delete_permissions_for_media_entries].present?
        delete_permissions_for(resource.user, resource)
      else
        grant_all_permissions_for(resource.user, resource)
      end
      resource.update_attributes(user: new_owner)
      @success_messages << 'Successfuly changed responsible user for children media entries'
    end
  end

  def transfer_children_sets(resource, new_owner)
    if params[:transfer_children_sets].present? && resource.type == 'MediaSet'
      if params[:delete_permissions_for_sets].present?
        delete_permissions_for(resource.user, resource)
      else
        grant_all_permissions_for(resource.user, resource)
      end
      resource.update_attributes(user: new_owner)
      @success_messages << 'Successfuly changed responsible user for children sets'
    end
  end

  def transfer_ownership_of_media_set(resource, new_owner)
    if params[:transfer_ownership].present?
      if params[:delete_permissions].present?
        delete_permissions_for(resource.user, resource)
      else
        grant_all_permissions_for(resource.user, resource)
      end
      resource.update_attributes(user: new_owner)

      @success_messages << 'Successfuly changed responsible user for the set'
    end
  end
end
