module Presenters
  module Shared
    module Clipboard

      private

      def clipboard_collection(user)
        Collection.unscoped.where(clipboard_user_id: user.id).first
      end
    end
  end
end
