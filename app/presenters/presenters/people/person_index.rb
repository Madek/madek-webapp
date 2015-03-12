module Presenters
  module People
    class PersonIndex < PersonCommon
      def url
        person_path(@app_resource)
      end

    end
  end
end
