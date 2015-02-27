class Admin::MetaKeysController < AdminController
  def index
    @meta_keys = MetaKey.with_vocables_count
                        .page(params[:page])
                        .per(16)

    filter
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

  def filter
    if (search_term = params[:search_term]).present?
      filter_by_term(search_term)
    end
    if (type = params[:type]).present?
      filter_by_type(type)
    end
  end

  def filter_by_term(term)
    @meta_keys =
      if term =~ /\Avocabulary_id:/
        @meta_keys.of_vocabulary(term.split('vocabulary_id:').last)
      else
        @meta_keys.filter_by(term)
      end
  end

  def filter_by_type(type)
    @meta_keys = @meta_keys.with_type(type)
  end

  def meta_key_params
    params.require(:meta_key).permit(:id,
                                     :meta_datum_object_type,
                                     :label,
                                     :description,
                                     :hint,
                                     :is_extensible_list,
                                     :vocables_are_user_extensible,
                                     :vocables_alphabetical_order,
                                     :vocabulary_id)
  end
end
