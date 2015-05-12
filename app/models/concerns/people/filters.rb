module Concerns
  module People
    module Filters
      extend ActiveSupport::Concern
      include Concerns::FilterBySearchTerm

      module ClassMethods
        def filter_by(term)
          filter_by_term_using_attributes(term, :searchable)
        end
      end
    end
  end
end
