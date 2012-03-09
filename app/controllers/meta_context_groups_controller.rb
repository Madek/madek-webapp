class MetaContextGroupsController < ApplicationController
  # GET /meta_context_groups
  # GET /meta_context_groups.json
  def index
    @meta_context_groups = MetaContextGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @meta_context_groups }
    end
  end

  # GET /meta_context_groups/1
  # GET /meta_context_groups/1.json
  def show
    @meta_context_group = MetaContextGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @meta_context_group }
    end
  end

  # GET /meta_context_groups/new
  # GET /meta_context_groups/new.json
  def new
    @meta_context_group = MetaContextGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @meta_context_group }
    end
  end

  # GET /meta_context_groups/1/edit
  def edit
    @meta_context_group = MetaContextGroup.find(params[:id])
  end

  # POST /meta_context_groups
  # POST /meta_context_groups.json
  def create
    @meta_context_group = MetaContextGroup.new(params[:meta_context_group])

    respond_to do |format|
      if @meta_context_group.save
        format.html { redirect_to @meta_context_group, notice: 'Meta context group was successfully created.' }
        format.json { render json: @meta_context_group, status: :created, location: @meta_context_group }
      else
        format.html { render action: "new" }
        format.json { render json: @meta_context_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /meta_context_groups/1
  # PUT /meta_context_groups/1.json
  def update
    @meta_context_group = MetaContextGroup.find(params[:id])

    respond_to do |format|
      if @meta_context_group.update_attributes(params[:meta_context_group])
        format.html { redirect_to @meta_context_group, notice: 'Meta context group was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @meta_context_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meta_context_groups/1
  # DELETE /meta_context_groups/1.json
  def destroy
    @meta_context_group = MetaContextGroup.find(params[:id])
    @meta_context_group.destroy

    respond_to do |format|
      format.html { redirect_to meta_context_groups_url }
      format.json { head :ok }
    end
  end
end
