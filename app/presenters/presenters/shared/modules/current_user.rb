module Presenters
  module Shared
    module Modules
      module CurrentUser
        def current_user
          ::Presenters::People::PersonIndex.new(@user.person) if @user
        end
      end
    end
  end
end
