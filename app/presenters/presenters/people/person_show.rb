module Presenters
  module People
    class PersonShow < PersonCommon
      %w(is_bunch
         date_of_birth
         date_of_death
         first_name
         last_name
         pseudonym
         searchable).each { |m| delegate m.to_sym, to: :@resource }
    end
  end
end
