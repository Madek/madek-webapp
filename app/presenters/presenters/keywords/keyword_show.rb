module Presenters
  module Keywords
    class KeywordShow < Presenters::Keywords::KeywordIndexWithUsageCount

      delegate_to_app_resource :description, :external_uri, :rdf_class

    end
  end
end
