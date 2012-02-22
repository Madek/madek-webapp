class Admin::PermissionPresetsController < Admin::AdminController
  # GET /permission_presets
  # GET /permission_presets.json
  def index
    @permission_presets = PermissionPreset.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @permission_presets }
    end
  end

  # GET /permission_presets/1
  # GET /permission_presets/1.json
  def show
    @permission_preset = PermissionPreset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @permission_preset }
    end
  end

  # GET /permission_presets/new
  # GET /permission_presets/new.json
  def new
    @permission_preset = PermissionPreset.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @permission_preset }
    end
  end

  # GET /permission_presets/1/edit
  def edit
    @permission_preset = PermissionPreset.find(params[:id])
  end

  # POST /permission_presets
  # POST /permission_presets.json
  def create
    @permission_preset = PermissionPreset.new(params[:permission_preset])

    respond_to do |format|
      if @permission_preset.save
        format.html { redirect_to admin_permission_presets_path, notice: 'Permission preset was successfully created.' }
        format.json { render json: @permission_preset, status: :created, location: @permission_preset }
      else
        format.html { render action: "new" }
        format.json { render json: @permission_preset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /permission_presets/1
  # PUT /permission_presets/1.json
  def update
    @permission_preset = PermissionPreset.find(params[:id])

    respond_to do |format|
      if @permission_preset.update_attributes(params[:permission_preset])
        format.html { redirect_to @permission_preset, notice: 'Permission preset was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @permission_preset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permission_presets/1
  # DELETE /permission_presets/1.json
  def destroy
    @permission_preset = PermissionPreset.find(params[:id])
    @permission_preset.destroy

    respond_to do |format|
      format.html { redirect_to admin_permission_presets_url }
      format.json { head :ok }
    end
  end
end
