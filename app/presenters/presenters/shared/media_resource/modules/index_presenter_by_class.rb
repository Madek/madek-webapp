module Presenters
  module Shared
    module MediaResource
      module Modules
        module IndexPresenterByClass
          extend ActiveSupport::Concern

          private

          def presenter_by_class(klass)
            case klass.name
            when 'MediaEntry' then Presenters::MediaEntries::MediaEntryIndex
            when 'Collection' then Presenters::Collections::CollectionIndex
            when 'FilterSet' then Presenters::FilterSets::FilterSetIndex
            when 'MediaResource' then nil
            else
              raise 'Unknown resource type!'
            end
          end

          def presenter_by_resource_type(resource)
            if resource.respond_to?(:cast_to_type)
              presenter_by_class(resource.cast_to_type.class)
            end
          end
        end
      end
    end
  end
end
