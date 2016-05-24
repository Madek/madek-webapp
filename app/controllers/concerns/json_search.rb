module Concerns
  module JSONSearch
    extend ActiveSupport::Concern
    include Concerns::Monads::FilterChain

    def get_and_respond_with_json
      ar_model = controller_name.classify.constantize
      presenter = 'Presenters::' \
                  "#{controller_name.camelize}::" \
                  "#{controller_name.singularize.camelize}Index" \
        .constantize

      scoped_ar_collection = policy_scope(ar_model.all)

      ar_collection = \
        FilterChain.new(scoped_ar_collection, self)
          .do(:filter_by_search_params, *search_params)
          .return
          .limit(params[:limit] || 100)

      get = ar_collection.map { |kt| presenter.new(kt).dump }
      respond_with get
    end

    # to be overriden in controllers if required
    def filter_by_search_params(ar_collection, *search_params)
      ar_collection.filter_by(*search_params)
    end

    # to be overriden in controllers if required
    def search_params
      [params[:search_term]]
    end
  end
end
