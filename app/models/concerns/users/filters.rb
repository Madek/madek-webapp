module Concerns
  module Users
    module Filters
      extend ActiveSupport::Concern
      include Concerns::FilterBySearchTerm

      included do
        scope :admin_users, -> { joins(:admin) }
        scope :filter_by, lambda { |term|
          filter_by_term_using_attributes(term, :login, :email)
        }
        scope :sort_by, lambda { |attribute|
          case attribute.to_sym
          when :first_name_last_name
            joins(:person)
              .reorder('people.first_name ASC, people.last_name ASC')
          else
            reorder(attribute)
          end
        }
      end
    end
  end
end
