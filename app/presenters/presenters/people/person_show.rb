module Presenters
  module People
    class PersonShow < PersonCommon
      # TODO: show person.searchable? (it's supposed to be internal…)
      %w(first_name
         last_name
         pseudonym
         date_of_birth
         date_of_death).each { |m| delegate m.to_sym, to: :@app_resource }

      def bunch?
        @app_resource.is_bunch
      end

    end
  end
end
