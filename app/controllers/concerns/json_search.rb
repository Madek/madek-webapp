module Concerns
  module JSONSearch
    extend ActiveSupport::Concern

    def get_and_respond_with_json
      ar_model = controller_name.classify.constantize
      presenter = 'Presenters::' \
                  "#{controller_name.camelize}::" \
                  "#{controller_name.singularize.camelize}Index" \
        .constantize

      ar_collection = search_or_return_unchanged(ar_model.all)
      get = ar_collection.map { |kt| presenter.new(kt).dump }
      respond_with get
    end

    def search_or_return_unchanged(ar_collection)
      if params[:search_term]
        ar_collection.filter_by(params[:search_term])
      else
        ar_collection
      end
    end
  end
end
