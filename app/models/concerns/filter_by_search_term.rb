module Concerns
  module FilterBySearchTerm
    extend ActiveSupport::Concern

    included do
      def self.filter_by_term_using_attributes(term, *attrs)
        sql_string = \
          attrs.map { |attr| "#{attr} ILIKE '%#{term}%'" }.join(' OR ')
        where(sql_string)
      end
    end
  end
end
