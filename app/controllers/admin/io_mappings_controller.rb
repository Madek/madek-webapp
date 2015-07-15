class Admin::IoMappingsController < AdminController

  def index
    @io_mappings = paginate filter IoMapping.all
  end

  def show
    @io_mapping = IoMapping.find(params[:id])
  end

  def new
    @io_mapping = IoMapping.new
  end

  def edit
    @io_mapping = IoMapping.find(params[:id])
  end

  def create
    io_mapping = IoMapping.create!(io_mapping_params)

    respond_with io_mapping, location: (lambda do
      edit_admin_io_mapping_path(io_mapping)
    end)
  end

  define_update_action_for(IoMapping)
  define_destroy_action_for(IoMapping)

  private

  def paginate(io_mappings)
    io_mappings.page(params[:page]).per(16)
  end

  def filter(io_mappings)
    filter_by_io_interface_id \
      filter_by_search_term \
        io_mappings
  end

  def filter_by_search_term(io_mappings)
    if params[:search_term]
      io_mappings.filter_by(params[:search_term])
    else
      io_mappings
    end
  end

  def filter_by_io_interface_id(io_mappings)
    if params[:io_interface_id]
      io_mappings.where(io_interface_id: params[:io_interface_id])
    else
      io_mappings
    end
  end

  def io_mapping_params
    params.require(:io_mapping).permit(:io_interface_id,
                                       :meta_key_id,
                                       :key_map,
                                       :key_map_type)
  end

  alias_method :update_io_mapping_params, :io_mapping_params
end
