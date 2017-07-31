module Presenters
  module Explore
    class KeywordExample < Presenters::Shared::AppResourceWithUser

      def sparse_props
        wanted_props = [:uuid, :url, :image_url]
        p = Presenters::MediaEntries::MediaEntryIndex.new(@app_resource, @user)
        p.dump(sparse_spec: wanted_props.map { |k| [k, {}] }.to_h)
      end
    end
  end
end
