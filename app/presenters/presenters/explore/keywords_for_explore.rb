module Presenters
  module Explore
    class KeywordsForExplore < Presenter

      include AuthorizationSetup
      include Presenters::Explore::Modules::ValuesForMetaKey

      def initialize(user, meta_key)
        @meta_key = meta_key
        @user = user
      end

      def meta_key_values
        shared_meta_key_values(
          @meta_key, @user, false, page_size: 12, start_index: 0)
      end
    end
  end
end
