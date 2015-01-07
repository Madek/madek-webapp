module Permissions
  module Modules
    module DefineDestroyIneffective
      extend ActiveSupport::Concern
      included do |base|
        def self.define_destroy_ineffective(dw_conditions = nil)
          define_singleton_method 'destroy_ineffective' do
            dw_conditions && dw_conditions.each do |where_condition|
              where(where_condition).destroy_all
            end
            yield if block_given?
          end
        end
      end
    end
  end
end
