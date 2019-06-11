# NOTE: for controllers and presenters!!!
#
# Provides 3 method to handle all permissions/authorization cases:
#
# `auth_authorize`: check `policy` and fail if not allowed ("let user do it!")
#
# `auth_policy`: check if User is allowed to do Action on Resource
#    ("do we show the action button to this user?")
#
# `auth_policy_scope`: given a "List of resources" (scope),
#    only return those that the User is allowed an Action on.
#    default action is "show", so the default scope is "ViewableScope"
#    ("Only give my the Thing the user can see/edit/…!")
#
# for Presenters, there is an additional shortcut:
# self.policy_for(user) === policy(user, @app_resource)

module AuthorizationSetup
  extend ActiveSupport::Concern
  include Pundit

  included do

    private

    def auth_authorize(record, *args)
      if uberadmin_mode
        skip_authorization
        record
      else
        authorize(record, *args)
      end
    end

    def auth_policy(user, *args)
      if uberadmin_mode(user)
        FakeUberadminPolicy.new # returns true for any actions
      else
        Pundit.policy!(user, *args)
      end
    end

    def auth_policy_scope(user, scope, special_scope = nil)
      skip_policy_scope # tell pundit that we know what we're doing

      # pass through everything for uberadmin
      return scope.all if uberadmin_mode(user)

      # use explicitly given scope or find the default one ("Viewable")
      if special_scope
        special_scope.new(user, scope).resolve
      else
        Pundit.policy_scope!(user, scope)
      end
    end

    def uberadmin_mode(user = current_user)
      # NOTE: uses instance var because we don't always have access to `session`
      user.is_a?(::User) and user.admin? \
        and user.admin.webapp_session_uberadmin_mode
    end

  end
end

class FakeUberadminPolicy
  def method_missing(*_args, &_block)
    true
  end
end
