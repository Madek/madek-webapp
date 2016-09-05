module Concerns
  module JSONSearch
    extend ActiveSupport::Concern

    def get_and_respond_with_json
      get = prepare_array_of_presenter_dumps
      respond_with get
    end

    def prepare_array_of_presenter_dumps
      ar_collection = policy_scope(model_klass.all)
      unless search_params.blank?
        ar_collection = ar_collection.filter_by(*search_params)
      end
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
  end
end
