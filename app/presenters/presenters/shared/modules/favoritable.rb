module Presenters
  module Shared
    module Modules
      module Favoritable

        def favored
          @user.present? and @app_resource.favored?(@user)
        end

        # TODO: rename
        def favorite_policy
          policy(@user).favor?
        end

      end
    end
  end
end
