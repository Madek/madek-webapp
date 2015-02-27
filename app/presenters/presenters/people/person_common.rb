module Presenters
  module People
    class PersonCommon < Presenter
      def initialize(person)
        @person = person
      end

      def name
        @person.to_s
      end
    end
  end
end
