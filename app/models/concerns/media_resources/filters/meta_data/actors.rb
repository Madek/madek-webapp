module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Actors
          extend ActiveSupport::Concern

          include Concerns::MediaResources::Filters::MetaData::Helpers

          included do
            %w(user group person).each do |actor_type|
              scope "filter_by_meta_datum_type_#{actor_type.pluralize}".to_sym,
                    lambda { |meta_key_id, id|
                      filter_by_meta_datum_actor_type(meta_key_id, id, actor_type)
                    }
            end
          end
        end
      end
    end
  end
end
