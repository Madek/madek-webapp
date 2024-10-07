module Presenters
  module Shared
    module Modules
      module Favoritable

        def favored
          @user.present? and @app_resource.favored?(@user)
        end

        def favorite_policy
          policy_for(@user).favor?
        end

      end
    end
  end
end
