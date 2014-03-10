class AppAdmin::MetaTermsController < AppAdmin::BaseController
  def index
    begin
      @meta_terms = MetaTerm.page(params[:page]).per(12)
      @filter_by = params.try(:[], :filter_by) || nil
      @sort_by = params.try(:[], :sort_by) || :en_gb_asc

      case @filter_by
      when 'is_used'
        @meta_terms = @meta_terms.is_used
      when 'keyword'
        @meta_terms = @meta_terms.with_keywords
      when 'term'
        @meta_terms = @meta_terms.with_meta_data
      when 'key_label'
        @meta_terms = @meta_terms.with_key_labels
      when 'key_hint'
        @meta_terms = @meta_terms.with_key_hints
      when 'key_description'
        @meta_terms = @meta_terms.with_key_descriptions
      else
      end

      case @sort_by
      when 'en_gb_desc'
        @meta_terms = @meta_terms.order('en_gb DESC')
      when 'de_ch_asc'
        @meta_terms = @meta_terms.order('de_ch ASC')
      when 'de_ch_desc'
        @meta_terms = @meta_terms.order('de_ch DESC')
      else
        @meta_terms= @meta_terms.order('en_gb ASC')
      end

    rescue Exception => e
      @meta_terms = MetaTerm.where("true = false").page(params[:page])
      @error_message= e.to_s
    end
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

  def destroy
    begin
      @meta_term = MetaTerm.find params[:id]
      unless @meta_term.is_used?
        @meta_term.destroy
        flash = {success: "The Meta Term has been deleted."}
      else
        message = {error: "The Meta Term is used and cannot be deleted."}
      end
      redirect_to app_admin_meta_terms_url, flash: flash
    rescue => e
      redirect_to :back, flash: {error: e.to_s}
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
