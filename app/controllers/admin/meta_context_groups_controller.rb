class Admin::MetaContextGroupsController < Admin::AdminController

  before_filter do
    @meta_context_group = MetaContextGroup.find(params[:id]) unless params[:id].blank?
  end

#####################################################

  def index
    @meta_context_groups = MetaContextGroup.all
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @meta_context_group = MetaContextGroup.new
    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def create
    @meta_context_group = MetaContextGroup.new(params[:meta_context_group])

    respond_to do |format|
      if @meta_context_group.save
        format.html { redirect_to admin_meta_context_groups_url, notice: 'Meta context group was successfully created.' }
      else
        format.html { render action: "new.js.erb" }
      end
    end
  end

  def update
    respond_to do |format|
      if @meta_context_group.update_attributes(params[:meta_context_group])
        format.js { render partial: "show", locals: {meta_context_group: @meta_context_group} }
      else
        format.js { render action: "edit" }
      end
    end
  end

  def destroy
    @meta_context_group.destroy
    respond_to do |format|
      format.html { redirect_to admin_meta_context_groups_url }
    end
  end

#####################################################

  def reorder(order_by_ids = params[:meta_context_group])
    MetaContextGroup.transaction do
      # using update_all (instead of update) to avoid instantiating (and validating) the object
      order_by_ids.each_with_index do |id, index|
        MetaContextGroup.update_all({position: (index+1)}, {id: id})
      end
    end

    respond_to do |format|
      format.js { render :nothing => true }
    end
  end


end
