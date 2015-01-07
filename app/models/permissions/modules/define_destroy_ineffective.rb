module Permissions
  module Modules
    module DefineDestroyIneffective
      extend ActiveSupport::Concern
      included do |base|
        def self.define_destroy_ineffective(destroy_where_conditions)
          define_singleton_method 'destroy_ineffective' do
            destroy_where_conditions.each do |where_condition|
              where(where_condition).destroy_all
            end
          end
        end
      end
    end
  end
end
