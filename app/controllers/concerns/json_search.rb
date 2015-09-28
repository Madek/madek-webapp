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

      ar_collection = \
        FilterChain.new(ar_model.all, self)
          .do(:filter_by_search_term, params[:search_term])
          .return
          .limit(params[:limit] || 100)

      get = ar_collection.map { |kt| presenter.new(kt).dump }
      respond_with get
    end

    def filter_by_search_term(ar_collection, search_term)
      ar_collection.filter_by(search_term)
    end
  end
end
