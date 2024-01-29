module Presenters
  module Shared
    module Modules
      module CurrentUser
        def current_user
          ::Presenters::Users::UserIndex.new(@user) if @user
        end
      end
    end
  end
end
