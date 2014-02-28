class AppAdmin::MetaTermsController < AppAdmin::BaseController
  def index
    @meta_terms = MetaTerm.page(params[:page]).per(12).order(:en_gb)
  end

  def edit
    @meta_term = MetaTerm.find(params[:id])
  end

  def update
    begin
      @meta_term = MetaTerm.find(params[:id])
      @meta_term.update_attributes! meta_term_params
      redirect_to app_admin_meta_terms_url, flash: {success: "A meta term has been updated"}
    rescue => e
      redirect_to edit_app_admin_meta_term_url(@meta_term), flash: {error: e.to_s}
    end
  end

  def form_transfer_resources
    @meta_term = MetaTerm.find  params[:id]
  end

  def transfer_resources
    begin
      @meta_term_originator = MetaTerm.find params[:id]
      @meta_term_receiver   = MetaTerm.find params[:id_receiver]

      ActiveRecord::Base.transaction do
        transfer_keywords
        transfer_meta_data
      end
      redirect_to app_admin_meta_terms_path, flash: {success: "The meta term's resources have been transfered"}
    rescue => e
      redirect_to app_admin_meta_terms_path, flash: {error: e.to_s}
    end
  end

  private
  def meta_term_params
    params.require(:meta_term).permit(:en_gb, :de_ch)
  end

  def transfer_keywords
    @meta_term_originator.keywords.each do |keyword|
      keyword.update_attribute :meta_term, @meta_term_receiver
    end
  end

  def transfer_meta_data
    @meta_term_receiver.meta_data << \
      @meta_term_originator.meta_data \
      .where("id not in (#{@meta_term_receiver.meta_data.select('"meta_data"."id"').to_sql})")
    @meta_term_originator.meta_data.destroy_all
  end
end
