class Admin::MetaKeysController < AdminController
  def index
    @meta_keys = MetaKey.with_keyword_terms_count
                        .page(params[:page])
                        .per(16)

    filter_and_sort
  end

  def show
    @meta_key = MetaKey.find(params[:id])
  end

  def new
    @meta_key = MetaKey.new
  end

  def create
    meta_key = MetaKey.create!(meta_key_params)

    redirect_to edit_admin_meta_key_path(meta_key), flash: {
      success: 'The meta key has been created.'
    }
  end

  def edit
    @meta_key = MetaKey.find(params[:id])
  end

  def update
    meta_key = MetaKey.find(params[:id])
    meta_key.update!(meta_key_params)

    redirect_to edit_admin_meta_key_path(meta_key), flash: {
      success: 'The meta key has been updated.'
    }
  end

  def destroy
    meta_key = MetaKey.find(params[:id])
    meta_key.destroy!

    redirect_to admin_meta_keys_path, flash: {
      success: 'The meta key has been deleted.'
    }
  end

  private

  def filter_and_sort
    if (search_term = params[:search_term]).present?
      filter_by_term(search_term)
    end
    if (vocabulary_id = params[:vocabulary_id]).present?
      filter_by_vocabulary(vocabulary_id)
    end
    if (type = params[:type]).present?
      filter_by_type(type)
    end
    sort
  end

  def filter_by_term(term)
    @meta_keys = @meta_keys.filter_by(term)
  end

  def filter_by_type(type)
    @meta_keys = @meta_keys.with_type(type)
  end

  def filter_by_vocabulary(id)
    @meta_keys = @meta_keys.of_vocabulary(id)
  end

  def meta_key_params
    params.require(:meta_key).permit(:id,
                                     :meta_datum_object_type,
                                     :label,
                                     :description,
                                     :hint,
                                     :is_extensible,
                                     :keywords_alphabetical_order,
                                     :vocabulary_id,
                                     :is_enabled_for_media_entries,
                                     :is_enabled_for_collections,
                                     :is_enabled_for_filter_sets)
  end

  def sort
    if params[:sort_by] == 'name_part'
      @meta_keys = @meta_keys.order_by_name_part
    end
  end
end
