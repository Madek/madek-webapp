module Concerns
  module Users
    module Responsible
      extend ActiveSupport::Concern

      included do
        define_user_related_data(:responsible_user)
        scope :in_responsibility_of, ->(user) { where(responsible_user: user) }
        singleton_class.send(:alias_method,
                             :filter_by_responsible_user,
                             :in_responsibility_of)
      end
    end
  end
end
