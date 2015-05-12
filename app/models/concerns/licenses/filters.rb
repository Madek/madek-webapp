module Concerns
  module Licenses
    module Filters
      extend ActiveSupport::Concern
      include Concerns::FilterBySearchTerm

      module ClassMethods
        def filter_by(term)
          filter_by_term_using_attributes(term, :label)
        end
      end
    end
  end
end
