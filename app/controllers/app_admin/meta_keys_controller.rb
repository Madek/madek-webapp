class AppAdmin::MetaKeysController < AppAdmin::BaseController
  def index
    @meta_keys = MetaKey.page(params[:page]).per(12)
  end

  def new
    @meta_key = MetaKey.new
  end

  def create
    begin
      @meta_key = MetaKey.create(meta_key_params)
      redirect_to app_admin_meta_keys_url, flash: {success: "A new meta key has been created"}
    rescue => e
      redirect_to new_app_admin_meta_key_path, flash: {error: e.to_s}
    end
  end

  private

  def meta_key_params
    params.require(:meta_key).permit!
  end
end
