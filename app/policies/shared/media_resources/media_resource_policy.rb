module Shared
  module MediaResources
    class MediaResourcePolicy < DefaultPolicy
      class Scope < Scope
        def resolve
          scope.viewable_by_user_or_public(user)
        end
      end

      def new?
        logged_in?
      end

      def create?
        new?
      end

      def show?
        if logged_in?
          record.viewable_by_user?(user)
        else
          record.viewable_by_public?
        end
      end

      def update?
        logged_in? and record.editable_by_user?(user)
      end

      def destroy?
        logged_in? and record.responsible_user == user
      end

      # TODO: policy for seeing the permissions?
      # TMP: just like the entry itself:
      alias_method :permissions?, :show?
      # or: like in v2(?), only who can edit the permissions can see them
      # alias_method :permissions?, :permissions_edit?

      def permissions_edit?
        logged_in? and user.can_edit_permissions_for?(record)
      end

      def permissions_update?
        permissions_edit?
      end
    end
  end
end
