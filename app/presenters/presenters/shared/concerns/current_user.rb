module Presenters
  module Shared
    module Concerns
      module CurrentUser
        def current_user
          ::Presenters::People::PersonIndex.new(@user.person) if @user
        end
      end
    end
  end
end
