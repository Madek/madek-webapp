class AppAdmin::MetaKeysController < AppAdmin::BaseController
  def index
    @meta_keys = MetaKey.page(params[:page]).per(12)

    if (label = params.try(:[], :filter).try(:[], :label)).present?
      @meta_keys = @meta_keys.where("meta_keys.id LIKE ?", "%#{label}%")
    end

    if (@meta_datum_object_type = params.try(:[], :filter).try(:[], :meta_datum_object_type)).present?
      @meta_keys = @meta_keys.where(meta_datum_object_type: @meta_datum_object_type)
    end

    if (@context = params.try(:[], :filter).try(:[], :context)).present?
      @meta_keys = @meta_keys.with_context(@context)
    end

    if (@is_used = params.try(:[], :filter).try(:[], :is_used)).present?
      @is_used = @is_used == "true" ? true : false
      @meta_keys = @meta_keys.used(@is_used)
    end
  end

  def new
    @meta_key = MetaKey.new
  end

  def create
    begin
      @meta_key = MetaKey.create(new_meta_key_params)
      redirect_to app_admin_meta_keys_url, flash: {success: "A new meta key has been created"}
    rescue => e
      redirect_to new_app_admin_meta_key_path, flash: {error: e.to_s}
    end
  end

  def edit
    @meta_key = MetaKey.find(params[:id])
    @meta_key.meta_terms.build
  end

  def update
    begin
      @meta_key = MetaKey.find(params[:id])
      @meta_key.update(meta_key_params)

      merge_meta_terms
      destroy_chosen_meta_terms
      update_meta_terms_positions

      redirect_to edit_app_admin_meta_key_url(@meta_key), flash: {success: "The meta key has been updated"}
    rescue => e
      redirect_to edit_app_admin_meta_key_url(@meta_key), flash: {error: e.to_s}
    end
  end

  def destroy
    begin
      @meta_key = MetaKey.find(params[:id])
      raise "Cannot delete an used meta key" if @meta_key.used?
      @meta_key.destroy

      redirect_to app_admin_meta_keys_url, flash: {success: "The meta key has been deleted"}
    rescue => e
      redirect_to app_admin_meta_keys_url, flash: {error: e.to_s}
    end
  end

  def apply_alphabetical_order
    meta_key = MetaKey.find(params[:id])
    @meta_term_ids = meta_key.meta_terms.reorder('term').map(&:id)
    render json: @meta_term_ids
  end

  private

  def new_meta_key_params
    params.require(:meta_key).permit!
  end

  def meta_key_params
    params.require(:meta_key).permit(:meta_terms_alphabetical_order, :is_extensible_list, meta_terms_attributes: [:id, :term])
  end

  def destroy_chosen_meta_terms
    if meta_terms_attributes = params[:meta_key][:meta_terms_attributes]
      meta_terms_attributes.each_value do |meta_term_attr|
        if meta_term_attr[:_destroy].to_i == 1
          meta_term = @meta_key.meta_terms.find(meta_term_attr[:id])
          @meta_key.meta_terms.delete(meta_term)
        end
      end
    end
  end

  def update_meta_terms_positions
    if meta_terms_positions = params[:meta_terms_positions]
      meta_terms_positions.split(',').each_with_index do |id, index|
        meta_term = @meta_key.meta_key_meta_terms.find_by(meta_term_id: id)
        meta_term.update_attribute(:position, index)
      end
    @meta_key.update_attribute(:meta_terms_alphabetical_order, false)
    end
  end

  def merge_meta_terms
    params[:reassign_term_id].each_pair do |k, v|
      next if v.blank?
      from = @meta_key.meta_terms.find(k)
      to = @meta_key.meta_terms.find(v)
      next if from == to
      from.reassign_meta_data_to_term(to, @meta_key)
    end if params[:reassign_term_id]
  end
end
