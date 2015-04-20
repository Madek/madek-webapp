module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Actors
          extend ActiveSupport::Concern

          include Concerns::MediaResources::Filters::MetaData::Helpers

          included do
            %w(user group person).each do |actor_type|
              method_name =  "filter_by_meta_datum_#{actor_type.pluralize}".to_sym
              scope method_name,
                    lambda { |id|
                      filter_by_meta_datum_actor_type(id, actor_type)
                    }
            end
          end
        end
      end
    end
  end
end
