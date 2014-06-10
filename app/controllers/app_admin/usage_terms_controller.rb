class AppAdmin::UsageTermsController < AppAdmin::BaseController
  def index
    begin 
      @usage_terms = UsageTerm.page(params[:page])
    rescue Exception => e
      @usage_terms = UsageTerm.where("true = false").page(params[:page])
      @error_message= e.to_s
    end

  end

  def new
    @usage_term = UsageTerm.new params[:usage_term]
  end

  def update
    begin
      @usage_term = UsageTerm.find(params[:id])
      @usage_term.update_attributes! usage_term_params
      redirect_to app_admin_usage_term_path(@usage_term), flash: {success: "The usage_term has been updated."}
    rescue => e
      redirect_to edit_app_admin_usage_term_path(@usage_term), flash: {error: e.to_s}
    end
  end

  def create
    begin
      @usage_term = UsageTerm.create! usage_term_params
      redirect_to app_admin_usage_term_path(@usage_term), flash: {success: "A new usage_term has been created."}
    rescue => e
      redirect_to new_app_admin_usage_term_path(@usage_term),flash: {error: e.to_s}
    end
  end

  def show
    @usage_term = UsageTerm.find params[:id]
  end

  def edit
    @usage_term = UsageTerm.find params[:id]
  end

  def destroy
    begin
      @usage_term = UsageTerm.find params[:id]
      @usage_term.destroy
      redirect_to app_admin_usage_terms_path, flash: {success: "The UsageTerm has been deleted."}
    rescue => e
      redirect_to :back, flash: {error: e.to_s}
    end
  end

  private

  def usage_term_params
    params.require(:usage_term).permit!
  end
end
