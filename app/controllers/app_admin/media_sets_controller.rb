
class AppAdmin::MediaSetsController < AppAdmin::BaseController

  before_filter only: [:show] do
    if (id = params[:id]) and (not id.blank?) and (id =~ /^\d+$/)
      if mr = MediaResource.find_by(previous_id: id)
        redirect_to app_admin_media_set_path(mr.id), status: 301
      end
    end
  end


  def index
    @media_sets = MediaSet.reorder("created_at DESC").page(params[:page]).per(16)

    if !params[:fuzzy_search].blank? && fuzzy_query=params[:fuzzy_search]
      @media_sets= @media_sets.joins(user: :person, meta_data: :meta_key) \
        .where("meta_keys.id = 'title'") \
        .fuzzy_search(
          {users: {login: fuzzy_query, email: fuzzy_query}, 
            people: {last_name: fuzzy_query, first_name: fuzzy_query},
            meta_data: {string: fuzzy_query}},false)
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

  def manage_individual_contexts 
    @media_set= MediaSet.find params[:media_set_id]
    @individual_contexts = @media_set.individual_contexts.reorder(:position,:id)
    @other_contexts = 
      if @individual_contexts.count > 0
        Context.where("id NOT IN (?)",@media_set.individual_context_ids).reorder(:position,id)
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
    @media_set.individual_contexts << @context
    redirect_to manage_app_admin_media_set_individual_contexts_path(@media_set), 
      flash: {success: "The context has been added to the media-set."}
  end

  private
  def media_set_params
    params.require(:media_set).permit(:id, :user_id)
  end
end
