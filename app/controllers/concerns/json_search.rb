module JSONSearch
  extend ActiveSupport::Concern

  def get_and_respond_with_json
    get = prepare_array_of_presenter_dumps
    respond_with get
  end

  def prepare_array_of_presenter_dumps
    ar_collection = auth_policy_scope(current_user, model_klass.all)
    unless search_params.blank?
      ar_collection = ar_collection.filter_by(*search_params)
    end
    ar_collection = skip_deactivated_records(ar_collection)
    ar_collection = skip_unassignable_records(ar_collection)
    ar_collection = ar_collection.limit(params[:limit] || 100)
    ar_collection.map { |kt| presenter.new(kt).dump }
  end

  def model_klass
    controller_name.classify.constantize
  end

  def presenter
    'Presenters::' \
      "#{controller_name.camelize}::" \
      "#{controller_name.singularize.camelize}Index" \
      .constantize
  end

  # to be overriden in controllers if required
  def search_params
    [params[:search_term]].compact
  end

  private

  def skip_deactivated_records(collection)
    if model_klass.columns_hash.key?('active_until')
      collection.where('now() <= active_until')
    else
      collection
    end
  end

  def skip_unassignable_records(collection)
    if model_klass.columns_hash.key?('is_assignable')
      collection.where(is_assignable: true)
    else
      collection
    end
  end
end
