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
      if uberadmin_edit_mode
        skip_authorization
        record
      elsif uberadmin_view_mode && view_query?(record, args)
        skip_authorization
        record
      else
        authorize(record, *args)
      end
    end

    def auth_policy(user, *args)
      if uberadmin_edit_mode(user)
        FakeUberadminPolicy.new # returns true for any actions
      elsif uberadmin_view_mode(user)
        FakeUberadminViewPolicy.new(Pundit.policy!(user, *args))
      else
        Pundit.policy!(user, *args)
      end
    end

    def auth_policy_scope(user, scope, special_scope = nil)
      skip_policy_scope # tell pundit that we know what we're doing

      # pass through everything for full uberadmin
      return scope.all if uberadmin_edit_mode(user)

      # view-only uberadmin: pass through unless the scope is specifically
      # about what the user may edit/manage, not just view
      if uberadmin_view_mode(user) && special_scope.to_s !~ /Editable|Manageable|Usable/
        return scope.all
      end

      # use explicitly given scope or find the default one ("Viewable")
      if special_scope
        special_scope.new(user, scope).resolve
      else
        Pundit.policy_scope!(user, scope)
      end
    end

    def uberadmin_toggled_on?(user)
      # NOTE: uses instance var because we don't always have access to `session`
      user.is_a?(User) and user.admin? \
        and user.admin.webapp_session_uberadmin_mode
    end

    def uberadmin_edit_mode(user = current_user)
      uberadmin_toggled_on?(user) and user.has_admin_permission?('uberadmin_edit')
    end

    def uberadmin_view_mode(user = current_user)
      uberadmin_toggled_on?(user) and (
        user.has_admin_permission?('uberadmin_view') or
        user.has_admin_permission?('uberadmin_edit')
      )
    end

    def view_query?(record, args)
      query = args.find { |a| a.is_a?(Symbol) or a.is_a?(String) } || "#{action_name}?"
      policy_class = Pundit::PolicyFinder.new(record).policy
      policy_class.respond_to?(:view_tier_queries) &&
        policy_class.view_tier_queries.include?(query.to_s.to_sym)
    end

  end
end

class FakeUberadminPolicy
  def method_missing(*_args, &_block)
    true
  end

  def respond_to_missing?(*_args)
    true
  end
end

class FakeUberadminViewPolicy
  def initialize(real_policy)
    @real_policy = real_policy
  end

  def method_missing(name, *args, &block)
    if @real_policy.class.view_tier_queries.include?(name)
      true
    else
      @real_policy.public_send(name, *args, &block)
    end
  end

  def respond_to_missing?(*_args)
    true
  end
end
