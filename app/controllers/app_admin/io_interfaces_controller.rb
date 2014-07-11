class AppAdmin::IoInterfacesController < AppAdmin::BaseController

  def index
    @io_interfaces = IoInterface.page(params[:page]).per(12)
  end

  def new
    @io_interface = IoInterface.new params[:io_interface]
  end

  def create
    begin
      @io_interface = IoInterface.create!(io_interface_params)
      redirect_to app_admin_io_interfaces_path,
        flash: {success: "A new io_interface has been created."}
    rescue => e
      redirect_to new_app_admin_io_interface_path(@io_interface), 
        flash: {error: e.to_s}
    end
  end

  def show
    @io_interface = IoInterface.find(params[:id])
  end

  def destroy
    begin
      @io_interface = IoInterface.find(params[:id])
      @io_interface.destroy
      redirect_to app_admin_io_interfaces_path, 
        flash: {success: "The IoInterface has been deleted."}
    rescue => e
      redirect_to :back, flash: {error: e.to_s}
    end
  end

  private

  def io_interface_params
    params.require(:io_interface).permit(:id, :description)
  end

end

