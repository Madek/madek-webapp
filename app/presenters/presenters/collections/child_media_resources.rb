module Presenters
  module Collections
    class ChildMediaResources < Presenters::MediaResources::MediaResources

      private

      def indexify(resources)
        resources.map do |resource|
          case resource.class.name
          when 'MediaEntry'
            Presenters::MediaEntries::MediaEntryIndex.new \
              MediaEntry.find(resource.id),
              @user
          when 'Collection'
            Presenters::Collections::CollectionIndex.new \
              Collection.find(resource.id),
              @user
          when 'FilterSet'
            Presenters::FilterSets::FilterSetIndex.new \
              FilterSet.find(resource.id),
              @user
          else
            raise 'Unknown resource type!'
          end
        end
      end

    end
  end
end
