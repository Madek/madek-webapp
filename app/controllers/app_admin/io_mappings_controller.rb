class AppAdmin::IoMappingsController < AppAdmin::BaseController

  before_action :set_params, only: [:show, :update, :destroy, :edit]

  def index
    @io_mappings = IoMapping.page(params[:page]).per(12)

    if (key_map = params.try(:[], :filter).try(:[], :search_key_map)).present?
        @io_mappings = @io_mappings.fuzzy_search(key_map: key_map)
    end

    if (io_interface = params.try(:[], :filter).try(:[], :io_interface)).present?
        @io_mappings = @io_mappings.where(io_interface_id: io_interface)
    end

    if (meta_key = params.try(:[], :filter).try(:[], :meta_key)).present?
        @io_mappings = @io_mappings.where(meta_key_id: meta_key)
    end
  end

  def new
    @io_mapping = IoMapping.new params[:io_mapping]
  end

  def update
    begin
      @io_mapping = IoMapping.find_by io_interface_id: @io_interface_id,
        meta_key_id: @meta_key_id
      @io_mapping.update_attributes!(io_mapping_params)
      redirect_to app_admin_io_mapping_path("#{@io_interface_id}"\
                                            ",#{@meta_key_id}"), 
        flash: {success: "The io_mapping has been updated."}
    rescue => e
      redirect_to edit_app_admin_io_mapping_path("#{@io_interface_id}"\
                                                 ",#{@meta_key_id}"), 
        flash: {error: e.to_s}
    end
  end

  def create
    begin
      @io_mapping = IoMapping.create!(io_mapping_params)
      redirect_to app_admin_io_mapping_path("#{@io_mapping.io_interface_id}"\
                                            ",#{@io_mapping.meta_key_id}"),
        flash: {success: "A new io_mapping has been created."}
    rescue => e
      redirect_to new_app_admin_io_mapping_path(@io_mapping),
        flash: {error: e.to_s}
    end
  end

  def show
    @io_mapping = IoMapping.find_by io_interface_id: @io_interface_id,
      meta_key_id: @meta_key_id
  end

  def edit
    @io_mapping = IoMapping.find_by io_interface_id: @io_interface_id,
      meta_key_id: @meta_key_id
  end

  def destroy
      @io_mapping = IoMapping.find_by io_interface_id: @io_interface_id,
        meta_key_id: @meta_key_id
      @io_mapping.destroy
      redirect_to app_admin_io_mappings_path,
        flash: {success: "The IoMapping has been deleted."}
  end

  private

  def io_mapping_params
    params.require(:io_mapping).permit(:key_map, :key_map_type,
                                       :meta_key_id, :io_interface_id)
  end

  def set_params
    primary_key = params[:id].split(',')
    @io_interface_id = primary_key[0]
    @meta_key_id = primary_key[1]
  end

end

