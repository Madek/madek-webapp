module Concerns
  module Users
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :admin_users, -> { joins(:admin) }
        scope :search_by_term, lambda { |term|
          where('login ILIKE :t OR email ILIKE :t', t: "%#{term}%")
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
