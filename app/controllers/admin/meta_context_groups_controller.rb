class Admin::MetaContextGroupsController < Admin::AdminController

  def index
    @meta_context_groups = MetaContextGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @meta_context_groups }
    end
  end

  def show
    @meta_context_group = MetaContextGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @meta_context_group }
    end
  end

  def new
    @meta_context_group = MetaContextGroup.new
    @path=admin_meta_context_groups_path

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @meta_context_group }
    end
  end

  def edit
    @meta_context_group = MetaContextGroup.find(params[:id])
    @path=admin_meta_context_group_path(@meta_context_group)
  end

  def create
    @meta_context_group = MetaContextGroup.new(params[:meta_context_group])

    respond_to do |format|
      if @meta_context_group.save
        format.html { redirect_to admin_meta_context_group_path(@meta_context_group), notice: 'Meta context group was successfully created.' }
        format.json { render json: @meta_context_group, status: :created, location: admin_meta_context_group_path(@meta_context_group) }
      else
        format.html { render action: "new" }
        format.json { render json: @meta_context_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @meta_context_group = MetaContextGroup.find(params[:id])

    respond_to do |format|
      if @meta_context_group.update_attributes(params[:meta_context_group])
        format.html { redirect_to admin_meta_context_group_path(@meta_context_group), notice: 'Meta context group was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @meta_context_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @meta_context_group = MetaContextGroup.find(params[:id])
    @meta_context_group.destroy

    respond_to do |format|
      format.html { redirect_to admin_meta_context_groups_url }
      format.json { head :ok }
    end
  end
end
