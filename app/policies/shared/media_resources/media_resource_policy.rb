module Shared
  module MediaResources
    class MediaResourcePolicy < DefaultPolicy
      class Scope < Scope
        def resolve
          scope.viewable_by_user_or_public(user)
        end
      end

      # just an alias with a more explicit name
      class ViewableScope < Scope
      end

      class EditableScope < Scope
        def resolve
          scope.editable_by_user(user)
        end
      end

      class ManageableScope < Scope # edit permissions
        def resolve
          scope.manageable_by_user(user)
        end
      end

      class ResponsibilityTransferableScope < Scope
        def resolve
          scope.where(responsible_user: user)
        end
      end

      def new?
        logged_in?
      end

      def create?
        new?
      end

      def show?
        visible?
      end

      def update?
        logged_in? and record.editable_by_user?(user)
      end

      def update_custom_urls?
        logged_in? and record.manageable_by_user?(user)
      end
      alias_method :edit_custom_urls?, :update_custom_urls?
      alias_method :custom_urls?, :show?
      alias_method :set_primary_custom_url?, :update_custom_urls?

      def destroy?
        logged_in? and record.responsible_user == user
      end

      def update_transfer_responsibility?
        logged_in? and record.responsible_user == user
      end
      alias_method :edit_transfer_responsibility?, :update_transfer_responsibility?

      def favor?
        logged_in? and visible?
      end

      def disfavor?
        logged_in? and visible?
      end

      # only logged in users can see the permissions (if they also see the Res.)
      def permissions?
        logged_in? and visible?
      end

      def permissions_edit?
        logged_in? and user.can_edit_permissions_for?(record)
      end
      alias_method :permissions_update?, :permissions_edit?

      private

      def visible?
        if logged_in?
          record.viewable_by_user?(user)
        else
          record.viewable_by_public?
        end
      end

    end
  end
end
