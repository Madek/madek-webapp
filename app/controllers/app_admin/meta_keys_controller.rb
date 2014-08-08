class AppAdmin::MetaKeysController < AppAdmin::BaseController
  def index
    @meta_keys = MetaKey.page(params[:page]).per(12)

    if (label = params.try(:[], :filter).try(:[], :label)).present?
      label      = label.strip
      @meta_keys = @meta_keys.search_with(label)
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
    @meta_key = MetaKey.find(id_from_params(:id))
    @meta_key.meta_terms.build
  end

  def update
    begin
      @meta_key = MetaKey.find(id_from_params(:id))
      @meta_key.update(meta_key_params)

      merge_meta_terms
      destroy_chosen_meta_terms

      redirect_to edit_app_admin_meta_key_url(@meta_key), flash: {success: "The meta key has been updated"}
    rescue => e
      redirect_to edit_app_admin_meta_key_url(@meta_key), flash: {error: e.to_s}
    end
  end

  def destroy
    begin
      @meta_key = MetaKey.find(id_from_params(:id))
      raise "Cannot delete an used meta key" if @meta_key.used?
      @meta_key.destroy

      redirect_to app_admin_meta_keys_url, flash: {success: "The meta key has been deleted."}
    rescue => e
      redirect_to app_admin_meta_keys_url, flash: {error: e.to_s}
    end
  end

  def move_up
    meta_key = MetaKey.find(id_from_params(:meta_key_id))
    meta_key_meta_term = meta_key.meta_key_meta_terms.find_by(meta_term_id: params[:id])
    ActiveRecord::Base.transaction do
      meta_key_meta_term.move_up
      meta_key.update_attribute(:meta_terms_alphabetical_order, false)
    end

    redirect_to edit_app_admin_meta_key_url(meta_key), flash: {success: "The position of the meta term has been updated"}
  rescue => e
    redirect_to edit_app_admin_meta_key_url(meta_key), flash: {error: e.to_s}
  end

  def move_down
    meta_key = MetaKey.find(id_from_params(:meta_key_id))
    meta_key_meta_term = meta_key.meta_key_meta_terms.find_by(meta_term_id: params[:id])
    ActiveRecord::Base.transaction do
      meta_key_meta_term.move_down
      meta_key.update_attribute(:meta_terms_alphabetical_order, false)
    end

    redirect_to edit_app_admin_meta_key_url(meta_key), flash: {success: "The position of the meta term has been updated"}
  rescue => e
    redirect_to edit_app_admin_meta_key_url(meta_key)
  end

  def change_type
    begin
      meta_key = MetaKey.find(params[:id])

      ActiveRecord::Base.transaction do
        meta_key.update_attributes!(meta_datum_object_type: 'MetaDatumMetaTerms')
        meta_key.meta_data.each do |mt|
          meta_term = MetaTerm.find_or_create_by!(term: mt.string.strip)
          meta_key.meta_terms << meta_term unless meta_key.meta_terms.exists?(term: meta_term.term)
          mt.update_attributes!(type: 'MetaDatumMetaTerms', string: '')
          meta_term.meta_data << mt
        end
        meta_key.sort_meta_terms
      end

      redirect_to edit_app_admin_meta_key_url(meta_key), flash: {success: "The type of the meta key has been changed."}
    rescue => e
      redirect_to edit_app_admin_meta_key_url(meta_key), flash: {error: e.to_s}
    end
  end

  private

  def new_meta_key_params
    params.require(:meta_key).permit!
  end

  def meta_key_params
    params.require(:meta_key).permit(:meta_terms_alphabetical_order, :is_extensible_list, meta_terms_attributes: [:id, :term])
  end

  def id_from_params(key)
    params[key].gsub('@', '/')
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

  def merge_meta_terms
    params[:reassign_term_id].each_pair do |originator_id, receiver_id|
      next if receiver_id.blank?
      originator = @meta_key.meta_terms.find(sanitize_id(originator_id))
      receiver   = @meta_key.meta_terms.find(sanitize_id(receiver_id))
      next if originator == receiver

      originator.transfer_meta_data_meta_terms_to receiver
      receiver.reload.meta_data.reload.map(&:media_resource).each(&:reindex)
      @meta_key.meta_key_meta_terms.where(meta_term_id: originator.id).destroy_all

    end if params[:reassign_term_id]
  end
end
