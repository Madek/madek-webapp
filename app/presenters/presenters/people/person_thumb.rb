module Presenters
  module People
    class PersonThumb < PersonCommon
      def url
        person_path(@person)
      end

      def generic_thumbnail_url
        'TODO'
      end
    end
  end
end
