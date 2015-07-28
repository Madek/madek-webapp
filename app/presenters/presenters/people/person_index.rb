module Presenters
  module People
    class PersonIndex < PersonCommon
      def url
        prepend_url_context_fucking_rails person_path(@app_resource)
      end

    end
  end
end
