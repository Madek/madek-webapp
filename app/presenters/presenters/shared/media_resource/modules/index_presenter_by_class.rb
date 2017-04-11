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

        end
      end
    end
  end
end
