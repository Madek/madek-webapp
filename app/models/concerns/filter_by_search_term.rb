module Concerns
  module FilterBySearchTerm
    extend ActiveSupport::Concern

    included do
      def self.filter_by_term_using_attributes(query, *attrs)
        tokens = tokenize(query)
        sql_string = \
          attrs.map { |attr| "#{attr} ILIKE ALL (array[#{tokens}])" }.join(' OR ')
        where(sql_string)
      end

      private

      def self.tokenize(string)
        return string unless string.is_a?(String)
        string.split(/[[:space:]]+|[[:punct:]]+/)
          .map { |token| "'%#{token}%'" }
          .join(', ')
      end
    end
  end

end
